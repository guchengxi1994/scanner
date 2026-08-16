use std::{
    collections::HashMap,
    ffi::OsStr,
    fs::File as StdFile,
    io::{Read, Seek, SeekFrom},
    sync::RwLock,
};

use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};

use super::difference::Difference;

const SAMPLE_SIZE: usize = 64 * 1024;
const HASH_BUFFER_SIZE: usize = 1024 * 1024;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct File {
    pub path: String,
    pub name: String,
    pub size: u64,
}

impl File {
    pub fn from_path(path: String) -> anyhow::Result<Self> {
        let path_ref = std::path::Path::new(&path);
        let name = path_ref
            .file_name()
            .unwrap_or(OsStr::new(""))
            .to_string_lossy()
            .to_string();

        if name.is_empty() {
            anyhow::bail!("Invalid file path")
        }

        Ok(Self {
            size: path_ref.metadata()?.len(),
            path,
            name,
        })
    }

    /// A small deterministic fingerprint filters most same-sized candidates
    /// before the expensive complete SHA-256 pass.
    pub fn get_file_hash(&self) -> anyhow::Result<String> {
        let mut file = StdFile::open(&self.path)?;
        let mut hasher = Sha256::new();
        hasher.update(self.size.to_le_bytes());

        let mut buffer = vec![0_u8; SAMPLE_SIZE];
        let first_read = file.read(&mut buffer)?;
        hasher.update(&buffer[..first_read]);

        if self.size > SAMPLE_SIZE as u64 {
            file.seek(SeekFrom::Start(
                self.size.saturating_sub(SAMPLE_SIZE as u64),
            ))?;
            let last_read = file.read(&mut buffer)?;
            hasher.update(&buffer[..last_read]);
        }

        Ok(format!("{:x}", hasher.finalize()))
    }

    pub fn get_full_hash(&self) -> anyhow::Result<String> {
        let mut file = StdFile::open(&self.path)?;
        let mut buffer = vec![0_u8; HASH_BUFFER_SIZE];
        let mut hasher = Sha256::new();

        loop {
            let bytes_read = file.read(&mut buffer)?;
            if bytes_read == 0 {
                break;
            }
            hasher.update(&buffer[..bytes_read]);
        }

        Ok(format!("{:x}", hasher.finalize()))
    }

    pub fn compare_hash(&self, other: &Self) -> bool {
        self.get_file_hash().ok() == other.get_file_hash().ok()
            && self.get_full_hash().ok() == other.get_full_hash().ok()
    }

    pub fn fuzzy_compare(&self, other: &Self) -> Difference {
        let max_value = std::cmp::max(self.name.len(), other.name.len());
        if max_value == 0 {
            return Difference {
                distance: 0,
                similarity: 1.0,
            };
        }

        let distance = levenshtein::levenshtein(&self.name, &other.name);
        Difference {
            distance,
            similarity: 1.0 - (distance as f64 / max_value as f64),
        }
    }
}

#[derive(Debug, Clone, Default)]
pub struct FileSet(pub HashMap<u64, Vec<File>>);

impl FileSet {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn update_list(&mut self, files: Vec<File>) {
        for file in files {
            self.0.entry(file.size).or_default().push(file);
        }
    }

    pub fn clear(&mut self) {
        self.0.clear();
    }
}

pub static GLOBAL_FILESET: Lazy<RwLock<FileSet>> = Lazy::new(|| RwLock::new(FileSet::new()));
