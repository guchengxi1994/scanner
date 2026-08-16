use flutter_rust_bridge::frb;

use crate::{
    frb_generated::StreamSink,
    project::{ProjectDetail, ProjectView, PROJECT_DETAIL_SINK},
};

#[frb(sync)]
pub fn project_scan_stream(s: StreamSink<ProjectDetail>) -> anyhow::Result<()> {
    let mut stream = PROJECT_DETAIL_SINK.write().unwrap();
    *stream = Some(s);
    anyhow::Ok(())
}

pub fn project_scan(p: String) {
    let pv = ProjectView { 0: p };
    if let Err(error) = pv.scan() {
        println!("[rust] error {error}");
    }
}

pub fn project_scan_really_fast(p: String) {
    let pv = ProjectView { 0: p };
    if let Err(error) = pv.scan_in_multi_threads() {
        println!("[rust] error {error}");
    }
}
