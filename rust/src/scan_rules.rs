use std::{path::Path, sync::RwLock};

use once_cell::sync::Lazy;
use regex::Regex;

/// Rules are encoded by Flutter as `directory:`, `glob:`, or `regex:` so the
/// bridge can keep using a plain string list and remains forwards compatible.
#[derive(Clone)]
pub struct ScanExclusionRules {
    directory_names: Vec<String>,
    path_matchers: Vec<Regex>,
}

static ACTIVE_SCAN_RULES: Lazy<RwLock<ScanExclusionRules>> =
    Lazy::new(|| RwLock::new(ScanExclusionRules::from_encoded(&[])));

pub fn set_active_rules(rules: &[String]) {
    if let Ok(mut active_rules) = ACTIVE_SCAN_RULES.write() {
        *active_rules = ScanExclusionRules::from_encoded(rules);
    }
}

pub fn active_rules() -> ScanExclusionRules {
    ACTIVE_SCAN_RULES
        .read()
        .map(|rules| rules.clone())
        .unwrap_or_else(|_| ScanExclusionRules::from_encoded(&[]))
}

impl ScanExclusionRules {
    pub fn from_encoded(rules: &[String]) -> Self {
        let mut directory_names = Vec::new();
        let mut path_matchers = Vec::new();

        for rule in rules {
            let Some((kind, pattern)) = rule.split_once(':') else {
                continue;
            };
            if pattern.trim().is_empty() {
                continue;
            }

            match kind {
                "directory" => directory_names.push(pattern.to_ascii_lowercase()),
                "glob" => match Regex::new(&glob_to_regex(pattern)) {
                    Ok(regex) => path_matchers.push(regex),
                    Err(error) => eprintln!("[rust] invalid exclusion glob {pattern:?}: {error}"),
                },
                "regex" => match Regex::new(pattern) {
                    Ok(regex) => path_matchers.push(regex),
                    Err(error) => eprintln!("[rust] invalid exclusion regex {pattern:?}: {error}"),
                },
                _ => {}
            }
        }

        Self {
            directory_names,
            path_matchers,
        }
    }

    pub fn should_skip(&self, path: &Path) -> bool {
        let has_excluded_directory = path.components().any(|component| {
            self.directory_names.iter().any(|excluded| {
                component
                    .as_os_str()
                    .to_string_lossy()
                    .eq_ignore_ascii_case(excluded)
            })
        });
        has_excluded_directory
            || self
                .path_matchers
                .iter()
                .any(|matcher| matcher.is_match(&path.to_string_lossy()))
    }
}

fn glob_to_regex(pattern: &str) -> String {
    let mut regex = String::from("(?i)");
    for character in pattern.chars() {
        match character {
            '*' => regex.push_str(".*"),
            '?' => regex.push('.'),
            '/' | '\\' => regex.push_str("[/\\\\]"),
            '.' | '+' | '(' | ')' | '|' | '^' | '$' | '{' | '}' | '[' | ']' => {
                regex.push('\\');
                regex.push(character);
            }
            _ => regex.push(character),
        }
    }
    regex
}

#[cfg(test)]
mod tests {
    use std::path::Path;

    use super::ScanExclusionRules;

    #[test]
    fn skips_matching_directory_components_only() {
        let rules = ScanExclusionRules::from_encoded(&["directory:node_modules".to_string()]);

        assert!(rules.should_skip(Path::new("/workspace/node_modules/index.js")));
        assert!(!rules.should_skip(Path::new("/workspace/node_modules_backup/index.js")));
    }

    #[test]
    fn supports_glob_and_regex_rules() {
        let rules = ScanExclusionRules::from_encoded(&[
            "glob:*.tmp".to_string(),
            r"regex:[/\\]scratch[/\\]".to_string(),
        ]);

        assert!(rules.should_skip(Path::new("/workspace/cache/session.tmp")));
        assert!(rules.should_skip(Path::new("/workspace/scratch/file.txt")));
        assert!(!rules.should_skip(Path::new("/workspace/documents/file.txt")));
    }
}
