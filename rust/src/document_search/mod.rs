use serde::Serialize;
use walkdir::WalkDir;

#[derive(Debug, Serialize)]
pub struct DocumentSearchResult {
    pub path: String,
    pub name: String,
    pub snippet: String,
    pub size: u64,
    pub match_count: u32,
}

pub fn search(root: String, query: String, max_results: u32) -> Vec<DocumentSearchResult> {
    let query = query.trim().to_lowercase();
    if query.is_empty() || max_results == 0 {
        return Vec::new();
    }

    let mut results = Vec::new();
    for entry in WalkDir::new(root)
        .follow_links(false)
        .into_iter()
        .filter_map(Result::ok)
    {
        if !entry.file_type().is_file() || anydoc::Format::from_path(entry.path()).is_none() {
            continue;
        }

        let Ok(markdown) = anydoc::to_markdown(entry.path()) else {
            continue;
        };
        let searchable = markdown.to_lowercase();
        let match_count = searchable.match_indices(&query).count() as u32;
        if match_count == 0 {
            continue;
        }

        results.push(DocumentSearchResult {
            path: entry.path().display().to_string(),
            name: entry.file_name().to_string_lossy().to_string(),
            snippet: excerpt(&markdown, searchable.find(&query).unwrap_or(0), query.len()),
            size: entry.metadata().map(|metadata| metadata.len()).unwrap_or_default(),
            match_count,
        });

        if results.len() >= max_results as usize {
            break;
        }
    }
    results
}

pub fn search_as_json(root: String, query: String, max_results: u32) -> Vec<String> {
    search(root, query, max_results)
        .into_iter()
        .filter_map(|result| serde_json::to_string(&result).ok())
        .collect()
}

fn excerpt(content: &str, match_start: usize, query_len: usize) -> String {
    let start = content[..match_start]
        .char_indices()
        .rev()
        .nth(90)
        .map(|(index, _)| index)
        .unwrap_or(0);
    let end = content[match_start..]
        .char_indices()
        .nth(160 + query_len)
        .map(|(index, _)| match_start + index)
        .unwrap_or(content.len());
    let text = content[start..end].replace(['\n', '\r'], " ");
    if start > 0 || end < content.len() {
        format!("...{}...", text.trim())
    } else {
        text.trim().to_string()
    }
}
