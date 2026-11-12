use crate::wgsl_dispatcher::GpuVectorScorer;
use crate::crystal::MemoryCrystal;
use std::time::{SystemTime, UNIX_EPOCH};

pub struct VectorCachePipeline {
    scorer: GpuVectorScorer,
}

impl VectorCachePipeline {
    pub async fn new() -> Self {
        Self {
            scorer: GpuVectorScorer::initialize().await,
        }
    }

    /// Executes GPU vector scoring and automatically caches results exceeding the threshold into a Memory Crystal.
    pub fn process_and_cache(
        &self, 
        query: &[f32], 
        database: &[f32], 
        dim: u32, 
        threshold: f32
    ) -> Result<MemoryCrystal, Box<dyn std::error::Error>> {
        // 1. Run batched parallel scoring via GPU WGSL compute pipeline
        let scores = self.scorer.score_vectors(query, database, dim);

        // 2. Get current epoch timestamp
        let timestamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)?
            .as_secs();

        // 3. Automatically filter and seal high-scoring matches into an immutable Crystal
        let crystal = MemoryCrystal::seal_vector_intersections(&scores, threshold, timestamp)?;

        Ok(crystal)
    }
}
