use std::time::{Duration, Instant};

use walkdir::WalkDir;

use super::{
    compare_result::CompareResult,
    event::{CompareEvent, DoneEvent, ResEvent, ScannerEvent, EVENT_SINK},
    file::{File, GLOBAL_FILESET},
    interface::Scanner,
};

const FLUSH_BATCH_SIZE: usize = 512;
const PROGRESS_INTERVAL: Duration = Duration::from_millis(250);

pub struct LocalScanner(pub String);

#[async_trait::async_trait]
impl Scanner for LocalScanner {
    async fn scan(&self) -> anyhow::Result<()> {
        let started_at = Instant::now();
        let mut pending = Vec::with_capacity(FLUSH_BATCH_SIZE);
        let mut file_count = 0_u64;
        let mut last_progress = Instant::now();

        Self::before_scan();
        send_scanner_event("Scanning files".to_string(), 0, 0.0);

        for entry in WalkDir::new(&self.0)
            .follow_links(false)
            .into_iter()
            .filter_map(Result::ok)
        {
            if !entry.file_type().is_file() {
                continue;
            }

            if let Ok(file) = File::from_path(entry.path().display().to_string()) {
                pending.push(file);
                file_count += 1;
            }

            if pending.len() >= FLUSH_BATCH_SIZE {
                Self::store_results(std::mem::take(&mut pending))?;
            }

            if last_progress.elapsed() >= PROGRESS_INTERVAL {
                send_scanner_event(
                    "Scanning files".to_string(),
                    file_count,
                    started_at.elapsed().as_secs_f32(),
                );
                last_progress = Instant::now();
            }
        }

        if !pending.is_empty() {
            Self::store_results(pending)?;
        }

        send_scanner_event(
            "Matching duplicate candidates".to_string(),
            file_count,
            started_at.elapsed().as_secs_f32(),
        );
        self.on_finished()?;
        send_done_event("Duplicate scan".to_string());
        Ok(())
    }

    fn on_finished(&self) -> anyhow::Result<()> {
        let compare_started_at = Instant::now();
        let file_set = GLOBAL_FILESET.read().unwrap().clone();
        let results = CompareResult::from_set(file_set);
        results.refresh();
        send_compare_event(
            "Duplicate scan".to_string(),
            compare_started_at.elapsed().as_secs_f32(),
        );
        Ok(())
    }

    fn store_results(files: Vec<File>) -> anyhow::Result<()> {
        GLOBAL_FILESET.write().unwrap().update_list(files);
        Ok(())
    }
}

fn send_scanner_event(event_type: String, count: u64, duration: f32) {
    if let Ok(sink) = EVENT_SINK.try_read() {
        if let Some(stream) = sink.as_ref() {
            let _ = stream.add(ResEvent::ScannerEvent(ScannerEvent {
                event_type,
                count,
                duration,
            }));
        }
    }
}

fn send_compare_event(event_type: String, duration: f32) {
    if let Ok(sink) = EVENT_SINK.try_read() {
        if let Some(stream) = sink.as_ref() {
            let _ = stream.add(ResEvent::CompareEvent(CompareEvent {
                event_type,
                duration,
            }));
        }
    }
}

fn send_done_event(event_type: String) {
    if let Ok(sink) = EVENT_SINK.try_read() {
        if let Some(stream) = sink.as_ref() {
            let _ = stream.add(ResEvent::DoneEvent(DoneEvent {
                event_type,
                is_done: true,
            }));
        }
    }
}
