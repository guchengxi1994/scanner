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
    fn find_duplicates<F>(
        files: Vec<File>,
        processed: &mut u64,
        total: &mut u64,
        on_progress: &mut F,
    ) -> Vec<Vec<File>>
    where
        F: FnMut(u64, u64),
    {
        let mut sample_groups: HashMap<String, Vec<File>> = HashMap::new();
        let mut empty_files = Vec::new();
        for file in files {
            *processed += 1;
            on_progress(*processed, *total);

            // Empty files have exactly the same content. Avoid opening every
            // zero-byte file twice when a cache contains a large number of them.
            if file.size == 0 {
                empty_files.push(file);
                continue;
            }
            if let Ok(hash) = file.get_file_hash() {
                sample_groups.entry(hash).or_default().push(file);
            }
        }

        let mut duplicates = Vec::new();
        if empty_files.len() > 1 {
            duplicates.push(empty_files);
        }
        for candidates in sample_groups.into_values().filter(|group| group.len() > 1) {
            // Files at or below the sample size were fully read for their
            // sample SHA-256, so a second full pass provides no extra signal.
            if candidates[0].size <= super::file::SAMPLE_SIZE as u64 {
                duplicates.push(candidates);
                continue;
            }

            *total += candidates.len() as u64;
            let mut full_groups: HashMap<String, Vec<File>> = HashMap::new();
            for file in candidates {
                *processed += 1;
                on_progress(*processed, *total);
                if let Ok(hash) = file.get_full_hash() {
                    full_groups.entry(hash).or_default().push(file);
                }
            }
            duplicates.extend(full_groups.into_values().filter(|group| group.len() > 1));
        }
        duplicates
    }

    pub fn from_set<F, R>(set: FileSet, mut on_progress: F, mut on_result: R) -> CompareResults
    where
        F: FnMut(u64, u64),
        R: FnMut(&CompareResult),
    {
        let mut buckets: Vec<(u64, Vec<File>)> = set
            .0
            .into_iter()
            .filter(|(_, files)| files.len() > 1)
            .collect();
        buckets.sort_by(|left, right| right.0.cmp(&left.0));

        let mut results = Vec::new();
        let mut processed = 0_u64;
        let mut total = buckets.iter().map(|(_, files)| files.len() as u64).sum();
        on_progress(processed, total);
        for (file_size, files) in buckets {
            let groups = Self::find_duplicates(files, &mut processed, &mut total, &mut on_progress);
            if groups.is_empty() {
                continue;
            }

            let count = groups.iter().map(|group| group.len() as u64).sum();
            let result = CompareResult {
                index: results.len() as u64 + 1,
                file_size,
                all_same_files: groups,
                count,
            };
            on_result(&result);
            results.push(result);
        }

        on_progress(processed, total);

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

pub fn send_result(result: &CompareResult) {
    if let Some(sink) = SCANNER_REFRESH_RESULTS_SINK.read().unwrap().as_ref() {
        let _ = sink.add(result.clone());
    }
}
