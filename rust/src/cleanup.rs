use std::{collections::HashMap, path::Path, sync::RwLock};

use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Deserialize)]
pub struct CleanupRule {
    pub id: String,
    pub scope: String,
    #[serde(rename = "matcherType")]
    pub matcher_type: String,
    #[serde(rename = "matcherValue")]
    pub matcher_value: String,
    pub enabled: bool,
}

#[derive(Debug, Clone, Serialize)]
pub struct CleanupCandidate {
    #[serde(rename = "ruleId")]
    pub rule_id: String,
    pub path: String,
    pub size: u64,
    pub count: u64,
}

static ACTIVE_CLEANUP_RULES: Lazy<RwLock<Vec<CleanupRule>>> = Lazy::new(|| RwLock::new(Vec::new()));

pub fn set_active_rules(encoded: &str) {
    let rules = serde_json::from_str::<Vec<CleanupRule>>(encoded).unwrap_or_default();
    if let Ok(mut active) = ACTIVE_CLEANUP_RULES.write() {
        *active = rules;
    }
}

pub fn active_rules() -> Vec<CleanupRule> {
    ACTIVE_CLEANUP_RULES
        .read()
        .map(|rules| rules.clone())
        .unwrap_or_default()
}

pub fn matching_rules(path: &Path, rules: &[CleanupRule]) -> Vec<CleanupRule> {
    rules
        .iter()
        .filter(|rule| rule.enabled && rule_matches(rule, path))
        .cloned()
        .collect()
}

fn rule_matches(rule: &CleanupRule, path: &Path) -> bool {
    let candidate = normalize(path);
    let scope = normalize(Path::new(&rule.scope));
    if !scope.is_empty() && candidate != scope && !candidate.starts_with(&format!("{scope}/")) {
        return false;
    }

    let value = normalize(Path::new(&rule.matcher_value));
    match rule.matcher_type.as_str() {
        "exactPath" => candidate == value,
        "directoryName" => candidate.rsplit('/').next().unwrap_or_default() == value,
        "pathContains" => candidate.contains(&value),
        _ => false,
    }
}

fn normalize(path: &Path) -> String {
    let normalized = path
        .to_string_lossy()
        .replace('\\', "/")
        .trim_end_matches('/')
        .to_string();
    if cfg!(target_os = "windows") || cfg!(target_os = "macos") {
        normalized.to_ascii_lowercase()
    } else {
        normalized
    }
}

pub fn candidate_key(rule_id: &str, path: &Path) -> String {
    format!("{rule_id}\0{}", normalize(path))
}

pub fn add_file_to_candidates(
    candidates: &mut HashMap<String, CleanupCandidate>,
    file_path: &Path,
    file_size: u64,
) {
    for candidate in candidates.values_mut() {
        if file_path.starts_with(Path::new(&candidate.path)) {
            candidate.size = candidate.size.saturating_add(file_size);
            candidate.count = candidate.count.saturating_add(1);
        }
    }
}
