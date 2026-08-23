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

/// Quick-hash sample size. Read only the first 1 MiB before deciding whether
/// sampled content validation is necessary.
pub const SAMPLE_SIZE: usize = 1024 * 1024;
const SMALL_FILE_LIMIT: u64 = 500 * 1024 * 1024;
const MEDIUM_FILE_LIMIT: u64 = 1024 * 1024 * 1024;
const LARGE_FILE_LIMIT: u64 = 3 * 1024 * 1024 * 1024;

#[derive(Clone)]
struct CachedHash {
    size: u64,
    modified: u128,
    value: String,
}

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

    /// Hash the first 1 MiB (or the whole file when it is smaller). This is
    /// intentionally one read per file in a same-size bucket.
    pub fn get_file_hash(&self) -> anyhow::Result<String> {
        self.get_cached_hash(&GLOBAL_FILE_HASH, || {
            let mut file = StdFile::open(&self.path)?;
            let mut hasher = Sha256::new();
            hasher.update(self.size.to_le_bytes());

            let mut buffer = vec![0_u8; SAMPLE_SIZE];
            let mut bytes_read = 0;
            while bytes_read < buffer.len() {
                let read = file.read(&mut buffer[bytes_read..])?;
                if read == 0 {
                    break;
                }
                bytes_read += read;
            }
            hasher.update(&buffer[..bytes_read]);

            Ok(format!("{:x}", hasher.finalize()))
        })
    }

    /// Build a content fingerprint from five fixed file positions instead of
    /// reading the entire file. The method name is kept for API compatibility.
    pub fn get_full_hash(&self) -> anyhow::Result<String> {
        self.get_cached_hash(&GLOBAL_FILE_SAMPLE_HASH, || {
            let mut file = StdFile::open(&self.path)?;
            let mut hasher = Sha256::new();
            hasher.update(self.size.to_le_bytes());

            // Files up to 1 MiB have already been read once by the fast
            // fingerprint, so keep the small-file path to a single read.
            if self.size <= SAMPLE_SIZE as u64 {
                let mut buffer = vec![0_u8; self.size as usize];
                file.read_exact(&mut buffer)?;
                hasher.update(0_u64.to_le_bytes());
                hasher.update(&buffer);
                return Ok(format!("{:x}", hasher.finalize()));
            }

            let chunk_size = sample_chunk_size(self.size);
            let max_offset = self.size - chunk_size as u64;
            let mut buffer = vec![0_u8; chunk_size];

            // Five deterministic points cover both edges and the interior:
            // 0%, 25%, 50%, 75%, and the last possible chunk.
            for point in 0_u64..=4 {
                let offset = max_offset.saturating_mul(point) / 4;
                file.seek(SeekFrom::Start(offset))?;
                file.read_exact(&mut buffer)?;
                hasher.update(offset.to_le_bytes());
                hasher.update(&buffer);
            }

            Ok(format!("{:x}", hasher.finalize()))
        })
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

fn sample_chunk_size(size: u64) -> usize {
    let megabyte = 1024 * 1024;
    if size <= SMALL_FILE_LIMIT {
        megabyte
    } else if size <= MEDIUM_FILE_LIMIT {
        3 * megabyte
    } else if size <= LARGE_FILE_LIMIT {
        5 * megabyte
    } else {
        10 * megabyte
    }
}

impl File {
    fn get_cached_hash<F>(
        &self,
        cache: &RwLock<HashMap<String, CachedHash>>,
        calculate: F,
    ) -> anyhow::Result<String>
    where
        F: FnOnce() -> anyhow::Result<String>,
    {
        let modified = std::fs::metadata(&self.path)
            .ok()
            .and_then(|metadata| metadata.modified().ok())
            .and_then(|time| time.duration_since(std::time::UNIX_EPOCH).ok())
            .map(|duration| duration.as_nanos())
            .unwrap_or_default();

        if let Some(cached) = cache.read().unwrap().get(&self.path) {
            if cached.size == self.size && cached.modified == modified {
                return Ok(cached.value.clone());
            }
        }

        let value = calculate()?;
        cache.write().unwrap().insert(
            self.path.clone(),
            CachedHash {
                size: self.size,
                modified,
                value: value.clone(),
            },
        );
        Ok(value)
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

/// Runtime hash caches. They survive individual scan tasks while validating
/// size and modification time on every lookup.
static GLOBAL_FILE_HASH: Lazy<RwLock<HashMap<String, CachedHash>>> =
    Lazy::new(|| RwLock::new(HashMap::new()));
static GLOBAL_FILE_SAMPLE_HASH: Lazy<RwLock<HashMap<String, CachedHash>>> =
    Lazy::new(|| RwLock::new(HashMap::new()));
