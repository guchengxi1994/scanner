use std::{sync::RwLock, time::SystemTime};

use walkdir::WalkDir;

use crate::frb_generated::StreamSink;

pub struct Period {
    pub start: Option<u64>,
    pub end: Option<u64>,
}

impl Period {
    pub fn new(start: Option<u64>, end: Option<u64>) -> Self {
        Period { start, end }
    }

    pub fn in_this_period(&self, time: SystemTime) -> bool {
        if self.start.is_none() && self.end.is_none() {
            return true;
        }

        if let Some(start) = self.start {
            if self.end.is_none() {
                if time
                    .duration_since(SystemTime::UNIX_EPOCH)
                    .unwrap()
                    .as_secs()
                    > start
                {
                    return true;
                }
            } else {
                if time
                    .duration_since(SystemTime::UNIX_EPOCH)
                    .unwrap()
                    .as_secs()
                    > start
                    && time
                        .duration_since(SystemTime::UNIX_EPOCH)
                        .unwrap()
                        .as_secs()
                        < self.end.unwrap()
                {
                    return true;
                }
            }
        } else if let Some(end) = self.end {
            if self.start.is_none() {
                if time
                    .duration_since(SystemTime::UNIX_EPOCH)
                    .unwrap()
                    .as_secs()
                    < self.end.unwrap()
                {
                    return true;
                }
                return false;
            } else {
                if time
                    .duration_since(SystemTime::UNIX_EPOCH)
                    .unwrap()
                    .as_secs()
                    > self.start.unwrap()
                    && time
                        .duration_since(SystemTime::UNIX_EPOCH)
                        .unwrap()
                        .as_secs()
                        < end
                {
                    return true;
                }
                return false;
            }
        }

        false
    }
}

pub struct HybridSearch {
    pub path: String,
    starts_with: Vec<Box<dyn Fn(&str) -> bool>>,
    ends_with: Vec<Box<dyn Fn(&str) -> bool>>,
    includes: Vec<Box<dyn Fn(&str) -> bool>>,
    excludes: Vec<Box<dyn Fn(&str) -> bool>>,
    regex: Vec<Box<dyn Fn(&str) -> bool>>,
    created_at: Vec<Box<dyn Fn(&Period) -> bool>>,
    modified_at: Vec<Box<dyn Fn(&Period) -> bool>>,
}

#[derive(Debug)]
pub enum SearchType {
    And,
    Or,
}

#[derive(Debug)]
pub struct HybridSearchDetail {
    pub path: String,
    pub created_epoch: u64,
    pub modified_epoch: u64,
}

pub static HYBRID_SEARCH_SINK: RwLock<Option<StreamSink<HybridSearchDetail>>> = RwLock::new(None);

impl HybridSearch {
    pub fn new(
        path: String,
        case_sensitive: bool,
        starts_with: Vec<String>,
        ends_with: Vec<String>,
        includes: Vec<String>,
        excludes: Vec<String>,
        regex: Vec<String>,
    ) -> Self {
        let starts_with_fn = starts_with
            .iter()
            .map(|s| {
                let s = s.clone();
                if !case_sensitive {
                    Box::new(move |name: &str| name.to_lowercase().starts_with(&s.to_lowercase()))
                        as Box<dyn Fn(&str) -> bool>
                } else {
                    Box::new(move |name: &str| name.starts_with(&s)) as Box<dyn Fn(&str) -> bool>
                }
            })
            .collect();

        let ends_with_fn = ends_with
            .iter()
            .map(|s| {
                let s = s.clone();
                if !case_sensitive {
                    Box::new(move |name: &str| name.to_lowercase().ends_with(&s.to_lowercase()))
                        as Box<dyn Fn(&str) -> bool>
                } else {
                    Box::new(move |name: &str| name.ends_with(&s)) as Box<dyn Fn(&str) -> bool>
                }
            })
            .collect();

        let includes_fn = includes
            .iter()
            .map(|s| {
                let s = s.clone();
                if !case_sensitive {
                    Box::new(move |name: &str| name.to_lowercase().contains(&s.to_lowercase()))
                        as Box<dyn Fn(&str) -> bool>
                } else {
                    Box::new(move |name: &str| name.contains(&s)) as Box<dyn Fn(&str) -> bool>
                }
            })
            .collect();

        let excludes_fn = excludes
            .iter()
            .map(|s| {
                let s = s.clone();
                if !case_sensitive {
                    Box::new(move |name: &str| !name.to_lowercase().contains(&s.to_lowercase()))
                        as Box<dyn Fn(&str) -> bool>
                } else {
                    Box::new(move |name: &str| !name.contains(&s)) as Box<dyn Fn(&str) -> bool>
                }
            })
            .collect();

        let regex_fn = regex
            .iter()
            .map(|s| {
                let s = s.clone();
                if !case_sensitive {
                    Box::new(move |name: &str| {
                        regex::Regex::new(&s)
                            .unwrap()
                            .is_match(name.to_lowercase().as_str())
                    }) as Box<dyn Fn(&str) -> bool>
                } else {
                    Box::new(move |name: &str| regex::Regex::new(&s).unwrap().is_match(name))
                        as Box<dyn Fn(&str) -> bool>
                }
            })
            .collect();
        HybridSearch {
            path,
            starts_with: starts_with_fn,
            ends_with: ends_with_fn,
            includes: includes_fn,
            excludes: excludes_fn,
            regex: regex_fn,
            created_at: vec![],
            modified_at: vec![],
        }
    }

    pub fn search(&self, search_type: SearchType) -> Vec<String> {
        let mut result = vec![];
        match search_type {
            SearchType::And => {
                for entry in WalkDir::new(&self.path).into_iter().filter_map(|e| e.ok()) {
                    let name = entry.path().display().to_string();
                    if if self.starts_with.is_empty() {
                        true
                    } else {
                        self.starts_with.iter().any(|f| f(&name))
                    } && if self.ends_with.is_empty() {
                        true
                    } else {
                        self.ends_with.iter().any(|f| f(&name))
                    } && if self.includes.is_empty() {
                        true
                    } else {
                        self.includes.iter().any(|f| f(&name))
                    } && if self.excludes.is_empty() {
                        true
                    } else {
                        self.excludes.iter().any(|f| f(&name))
                    } && if self.regex.is_empty() {
                        true
                    } else {
                        self.regex.iter().any(|f| f(&name))
                    } {
                        result.push(name);
                    }
                }
            }
            SearchType::Or => {
                for entry in WalkDir::new(&self.path).into_iter().filter_map(|e| e.ok()) {
                    let name = entry.path().display().to_string();
                    if if self.starts_with.is_empty() {
                        true
                    } else {
                        self.starts_with.iter().any(|f| f(&name))
                    } || if self.ends_with.is_empty() {
                        true
                    } else {
                        self.ends_with.iter().any(|f| f(&name))
                    } || if self.includes.is_empty() {
                        true
                    } else {
                        self.includes.iter().any(|f| f(&name))
                    } || if self.excludes.is_empty() {
                        true
                    } else {
                        self.excludes.iter().any(|f| f(&name))
                    } || if self.regex.is_empty() {
                        true
                    } else {
                        self.regex.iter().any(|f| f(&name))
                    } {
                        result.push(name);
                    }
                }
            }
        }

        result
    }

    pub fn search_stream(&self, search_type: SearchType) -> anyhow::Result<()> {
        match search_type {
            SearchType::And => {
                for entry in WalkDir::new(&self.path).into_iter().filter_map(|e| e.ok()) {
                    let name = entry.path().display().to_string();
                    if if self.starts_with.is_empty() {
                        true
                    } else {
                        self.starts_with.iter().any(|f| f(&name))
                    } && if self.ends_with.is_empty() {
                        true
                    } else {
                        self.ends_with.iter().any(|f| f(&name))
                    } && if self.includes.is_empty() {
                        true
                    } else {
                        self.includes.iter().any(|f| f(&name))
                    } && if self.excludes.is_empty() {
                        true
                    } else {
                        self.excludes.iter().any(|f| f(&name))
                    } && if self.regex.is_empty() {
                        true
                    } else {
                        self.regex.iter().any(|f| f(&name))
                    } {
                        let meta = entry.metadata()?;
                        let detail = HybridSearchDetail {
                            path: name,
                            created_epoch: meta
                                .created()?
                                .duration_since(std::time::SystemTime::UNIX_EPOCH)?
                                .as_secs(),
                            modified_epoch: meta
                                .modified()?
                                .duration_since(std::time::SystemTime::UNIX_EPOCH)?
                                .as_secs(),
                        };
                        send_detail_event(detail);
                    }
                }
            }
            SearchType::Or => {
                for entry in WalkDir::new(&self.path).into_iter().filter_map(|e| e.ok()) {
                    let name = entry.path().display().to_string();
                    if if self.starts_with.is_empty() {
                        true
                    } else {
                        self.starts_with.iter().any(|f| f(&name))
                    } || if self.ends_with.is_empty() {
                        true
                    } else {
                        self.ends_with.iter().any(|f| f(&name))
                    } || if self.includes.is_empty() {
                        true
                    } else {
                        self.includes.iter().any(|f| f(&name))
                    } || if self.excludes.is_empty() {
                        true
                    } else {
                        self.excludes.iter().any(|f| f(&name))
                    } || if self.regex.is_empty() {
                        true
                    } else {
                        self.regex.iter().any(|f| f(&name))
                    } {
                        let meta = entry.metadata()?;
                        let detail = HybridSearchDetail {
                            path: name,
                            created_epoch: meta
                                .created()?
                                .duration_since(std::time::SystemTime::UNIX_EPOCH)?
                                .as_secs(),
                            modified_epoch: meta
                                .modified()?
                                .duration_since(std::time::SystemTime::UNIX_EPOCH)?
                                .as_secs(),
                        };
                        send_detail_event(detail);
                    }
                }
            }
        }

        anyhow::Ok(())
    }
}

fn send_detail_event(detail: HybridSearchDetail) {
    let mut stream = HYBRID_SEARCH_SINK.write().unwrap();
    if let Some(s) = stream.as_mut() {
        let _ = s.add(detail);
    }
}
