use flutter_rust_bridge::frb;

use crate::{
    frb_generated::StreamSink,
    hybrid_search::{HybridSearch, HybridSearchDetail, SearchType, HYBRID_SEARCH_SINK},
};

const CONTENT_SEARCH_PREFIX: &str = "__anydoc_content_search__:";

pub fn hybrid_search_sync(
    p: String,
    case_sensitive: bool,
    starts_with: Vec<String>,
    ends_with: Vec<String>,
    includes: Vec<String>,
    excludes: Vec<String>,
    regex: Vec<String>,
    search_type: SearchType,
) -> Vec<String> {
    if let Some(query) = regex
        .iter()
        .find_map(|value| value.strip_prefix(CONTENT_SEARCH_PREFIX))
    {
        return crate::document_search::search_as_json(p, query.to_string(), 100);
    }

    let h = HybridSearch::new(
        p,
        case_sensitive,
        starts_with,
        ends_with,
        includes,
        excludes,
        regex,
    );
    h.search(search_type)
}

#[frb(sync)]
pub fn search_stream(s: StreamSink<HybridSearchDetail>) -> anyhow::Result<()> {
    let mut stream = HYBRID_SEARCH_SINK.write().unwrap();
    *stream = Some(s);
    anyhow::Ok(())
}

pub fn hybrid_search_stream(
    p: String,
    case_sensitive: bool,
    starts_with: Vec<String>,
    ends_with: Vec<String>,
    includes: Vec<String>,
    excludes: Vec<String>,
    regex: Vec<String>,
    search_type: SearchType,
) {
    let h = HybridSearch::new(
        p,
        case_sensitive,
        starts_with,
        ends_with,
        includes,
        excludes,
        regex,
    );
    let r = h.search_stream(search_type);
    match r {
        Ok(_) => {}
        Err(_e) => {
            println!("[rust] error {}", _e);
        }
    }
}
