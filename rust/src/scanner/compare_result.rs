use std::sync::RwLock;

use crate::frb_generated::StreamSink;

use super::file::{File, FileSet};

#[derive(Debug)]
pub struct CompareResult {
    pub index: u64,
    pub group_id: u64,
    pub files: Vec<File>,
}

#[derive(Debug)]
pub struct CompareResults(pub Vec<CompareResult>);

impl CompareResult {
    pub fn from_set(set: FileSet) -> CompareResults {
        let mut i = 0;
        let mut result = Vec::new();
        for (group_id, files) in set.0 {
            i += 1;
            result.push(CompareResult {
                index: i,
                group_id,
                files,
            });
        }

        CompareResults(result)
    }
}

pub static SCANNER_COMPARE_RESULTS_SINK: RwLock<Option<StreamSink<CompareResults>>> =
    RwLock::new(None);