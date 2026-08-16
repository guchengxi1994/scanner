use flutter_rust_bridge::frb;

use crate::{
    frb_generated::StreamSink,
    scanner::{
        compare_result::{CompareResult, SCANNER_REFRESH_RESULTS_SINK},
        event::{ResEvent, EVENT_SINK},
        interface::Scanner,
        local::LocalScanner,
    },
};

// #[frb(sync)]
// pub fn scanner_compare_results_stream(s: StreamSink<CompareResults>) -> anyhow::Result<()> {
//     let mut stream = SCANNER_COMPARE_RESULTS_SINK.write().unwrap();
//     *stream = Some(s);
//     anyhow::Ok(())
// }

#[frb(sync)]
pub fn scanner_refresh_results_stream(s: StreamSink<CompareResult>) -> anyhow::Result<()> {
    let mut stream = SCANNER_REFRESH_RESULTS_SINK.write().unwrap();
    *stream = Some(s);
    anyhow::Ok(())
}

#[frb(sync)]
pub fn event_stream(s: StreamSink<ResEvent>) -> anyhow::Result<()> {
    let mut stream = EVENT_SINK.write().unwrap();
    *stream = Some(s);
    anyhow::Ok(())
}

pub fn scan(p: String) {
    let rt = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .unwrap();

    rt.block_on(async {
        let s = LocalScanner { path: p };
        let r = s.scan().await;
        match r {
            Ok(_) => {}
            Err(e) => {
                println!("[rust] error {}", e);
            }
        }
    });
}

#[frb(sync)]
pub fn event_to_string(s: ResEvent) -> String {
    s.to_string()
}
