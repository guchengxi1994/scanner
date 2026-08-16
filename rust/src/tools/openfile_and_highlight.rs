use std::{path::Path, process::Command};

pub fn open_folder_and_highlight_file(file_path: &str) {
    let path = Path::new(file_path);

    if let Some(parent) = path.parent() {
        // 检查当前操作系统
        if cfg!(target_os = "windows") {
            Command::new("explorer")
                .arg("/select,")
                .arg(path)
                .spawn()
                .expect("Failed to open file in Explorer");
        } else if cfg!(target_os = "macos") {
            Command::new("open")
                .arg("-R")
                .arg(path)
                .spawn()
                .expect("Failed to open file in Finder");
        } else if cfg!(target_os = "linux") {
            Command::new("xdg-open")
                .arg(parent)
                .spawn()
                .expect("Failed to open file in file manager");
        } else {
            eprintln!("Unsupported operating system");
        }
    } else {
        eprintln!("Invalid file path");
    }
}

pub fn open_folder(file_path: &str) {
    let path = Path::new(file_path);
    if path.is_dir() {
        if cfg!(target_os = "windows") {
            Command::new("explorer")
                .arg(file_path)
                .spawn()
                .expect("Failed to open folder in Explorer");
        } else if cfg!(target_os = "macos") {
            Command::new("open")
                .arg(file_path)
                .spawn()
                .expect("Failed to open folder in Finder");
        } else if cfg!(target_os = "linux") {
            Command::new("xdg-open")
                .arg(file_path)
                .spawn()
                .expect("Failed to open folder in file manager");
        } else {
            eprintln!("Unsupported operating system");
        }
    } else if path.is_file() {
        open_folder_and_highlight_file(file_path);
    }
}
