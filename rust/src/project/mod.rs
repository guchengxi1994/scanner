use std::{
    path::PathBuf,
    sync::RwLock,
    time::{Duration, Instant},
};

use walkdir::WalkDir;

use crate::frb_generated::StreamSink;

const PROGRESS_INTERVAL: Duration = Duration::from_millis(200);

#[derive(Debug)]
pub struct ProjectDetail {
    pub path: String,
    pub size: u64,
    pub count: u64,
}

pub static PROJECT_DETAIL_SINK: RwLock<Option<StreamSink<ProjectDetail>>> = RwLock::new(None);

fn send_detail_event(detail: ProjectDetail) {
    if let Ok(sink) = PROJECT_DETAIL_SINK.try_read() {
        if let Some(stream) = sink.as_ref() {
            let _ = stream.add(detail);
        }
    }
}

fn send_progress_event(
    current_path: String,
    scanned_files: u64,
    scanned_bytes: u64,
    completed_roots: u64,
    total_roots: u64,
    is_done: bool,
) {
    // This stream already has a stable Flutter-Rust Bridge type. A reserved
    // path marker carries lightweight progress without creating a second,
    // high-frequency channel that would increase UI work during large scans.
    send_detail_event(ProjectDetail {
        path: format!(
            "__scanner_progress__:{completed_roots}:{total_roots}:{is_done}:{current_path}"
        ),
        size: scanned_bytes,
        count: scanned_files,
    });
}

pub struct ProjectView(pub String);

impl ProjectView {
    /// Computes every top-level entry with a single traversal per subtree.
    /// The old implementation repeatedly walked the selected root for each
    /// child, multiplying I/O cost on directories with many top-level items.
    pub fn scan(&self) -> anyhow::Result<()> {
        let roots: Vec<PathBuf> = WalkDir::new(&self.0)
            .follow_links(false)
            .min_depth(1)
            .max_depth(1)
            .into_iter()
            .filter_map(Result::ok)
            .map(|entry| entry.into_path())
            .collect();
        let total_roots = roots.len() as u64;
        let mut scanned_files = 0_u64;
        let mut scanned_bytes = 0_u64;
        let mut last_progress = Instant::now();

        for (root_index, root) in roots.into_iter().enumerate() {
            let root_label = root.display().to_string();
            let mut root_size = 0_u64;
            let mut root_count = 0_u64;

            if root.is_file() {
                if let Ok(metadata) = root.metadata() {
                    root_size = metadata.len();
                    root_count = 1;
                    scanned_files += 1;
                    scanned_bytes += root_size;
                }
            } else {
                for entry in WalkDir::new(&root)
                    .follow_links(false)
                    .into_iter()
                    .filter_map(Result::ok)
                {
                    if !entry.file_type().is_file() {
                        continue;
                    }
                    if let Ok(metadata) = entry.metadata() {
                        root_size += metadata.len();
                        root_count += 1;
                        scanned_files += 1;
                        scanned_bytes += metadata.len();
                    }

                    if last_progress.elapsed() >= PROGRESS_INTERVAL {
                        send_progress_event(
                            root_label.clone(),
                            scanned_files,
                            scanned_bytes,
                            root_index as u64,
                            total_roots,
                            false,
                        );
                        last_progress = Instant::now();
                    }
                }
            }

            send_detail_event(ProjectDetail {
                path: root_label.clone(),
                size: root_size,
                count: root_count,
            });
            send_progress_event(
                root_label,
                scanned_files,
                scanned_bytes,
                root_index as u64 + 1,
                total_roots,
                false,
            );
        }

        send_progress_event(
            self.0.clone(),
            scanned_files,
            scanned_bytes,
            total_roots,
            total_roots,
            true,
        );
        Ok(())
    }

    /// Kept for the existing bridge API. Parallel full-tree walks tend to
    /// saturate disks and leave the desktop app less responsive, so the
    /// optimized one-pass scanner is intentionally used for both modes.
    pub fn scan_in_multi_threads(&self) -> anyhow::Result<()> {
        self.scan()
    }
}
