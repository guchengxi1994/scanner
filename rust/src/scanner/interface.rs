use super::file::{File, GLOBAL_FILESET};

#[async_trait::async_trait]
pub trait Scanner {
    async fn scan(&self) -> anyhow::Result<()>;

    fn store_results(p: Vec<File>) -> anyhow::Result<()>;

    fn on_finished(&self) -> anyhow::Result<()>;

    fn before_scan() {
        let mut fileset = GLOBAL_FILESET.write().unwrap();
        (*fileset).clear();
    }
}
