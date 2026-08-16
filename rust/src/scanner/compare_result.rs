use std::{collections::HashMap, sync::RwLock};

use crate::frb_generated::StreamSink;
use serde::{Deserialize, Serialize};

use super::file::{File, FileSet};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompareResult {
    pub index: u64,
    pub file_size: u64,
    pub all_same_files: Vec<Vec<File>>,
    pub count: u64,
}

#[derive(Debug, Clone)]
pub struct CompareResults(pub Vec<CompareResult>);

impl CompareResult {
    fn find_duplicates(files: Vec<File>) -> Vec<Vec<File>> {
        let mut sample_groups: HashMap<String, Vec<File>> = HashMap::new();
        for file in files {
            if let Ok(hash) = file.get_file_hash() {
                sample_groups.entry(hash).or_default().push(file);
            }
        }

        let mut duplicates = Vec::new();
        for candidates in sample_groups.into_values().filter(|group| group.len() > 1) {
            let mut full_groups: HashMap<String, Vec<File>> = HashMap::new();
            for file in candidates {
                if let Ok(hash) = file.get_full_hash() {
                    full_groups.entry(hash).or_default().push(file);
                }
            }
            duplicates.extend(full_groups.into_values().filter(|group| group.len() > 1));
        }
        duplicates
    }

    pub fn from_set(set: FileSet) -> CompareResults {
        let mut buckets: Vec<(u64, Vec<File>)> = set
            .0
            .into_iter()
            .filter(|(_, files)| files.len() > 1)
            .collect();
        buckets.sort_by(|left, right| right.0.cmp(&left.0));

        let mut results = Vec::new();
        for (file_size, files) in buckets {
            let groups = Self::find_duplicates(files);
            if groups.is_empty() {
                continue;
            }

            let count = groups.iter().map(|group| group.len() as u64).sum();
            results.push(CompareResult {
                index: results.len() as u64 + 1,
                file_size,
                all_same_files: groups,
                count,
            });
        }

        CompareResults(results)
    }
}

impl CompareResults {
    pub fn refresh(&self) {
        if let Some(sink) = SCANNER_REFRESH_RESULTS_SINK.read().unwrap().as_ref() {
            for result in &self.0 {
                let _ = sink.add(result.clone());
            }
        }
    }
}

pub static SCANNER_REFRESH_RESULTS_SINK: RwLock<Option<StreamSink<CompareResult>>> =
    RwLock::new(None);
