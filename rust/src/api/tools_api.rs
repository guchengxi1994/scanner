use crate::tools::{
    self, move_file_to_trash::move_file_to_trash,
    openfile_and_highlight::open_folder_and_highlight_file,
};

use super::public::OperationResult;

pub fn open_file(s: String) {
    open_folder_and_highlight_file(&s)
}

pub fn open_folder(s: String) {
    tools::openfile_and_highlight::open_folder(&s)
}

pub fn remove_file(s: String) -> OperationResult {
    let r = move_file_to_trash(&s);

    if r.is_ok() {
        OperationResult::file_remove_ok()
    } else {
        OperationResult::file_remove_failed()
    }
}
