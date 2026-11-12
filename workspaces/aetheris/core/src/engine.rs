// ============================================================================
// File: core/src/engine.rs
// Wonderland Sovereign Core - Unified Vector & Operational Execution Engine
// ============================================================================

use std::sync::atomic::{AtomicU64, Ordering};
use std::time::Instant;

#[cfg(target_arch = "aarch64")]
use std::arch::aarch64::*;

/// Global atomic tracking throughput across high-frequency NEON vector operations.
static GLOBAL_VECTOR_THROUGHPUT: AtomicU64 = AtomicU64::new(0);

/// Core operational execution engine combining SIMD acceleration, corpus management,
/// and micro-sandbox telemetry states.
pub struct OperationalEngine {
    pub dimension: usize,
    pub corpus: Vec<Vec<f32>>,
    active_vm_state: bool,
}

impl OperationalEngine {
    /// Instantiates a new operational execution engine with bounded dimensionality.
    pub fn new(dimension: usize) -> Self {
        Self {
            dimension,
            corpus: Vec::new(),
            active_vm_state: false,
        }
    }

    /// Appends a target vector embedding to the active corpus after strict dimension validation.
    pub fn add_vector(&mut self, vector: Vec<f32>) -> Result<(), &'static str> {
        if vector.len() != self.dimension {
            return Err("Dimension mismatch: Vector length violates engine constraints.");
        }
        self.corpus.push(vector);
        Ok(())
    }

    /// Toggles the local micro-VM runtime state flag.
    pub fn set_vm_active(&mut self, active: bool) {
        self.active_vm_state = active;
    }

    /// Returns the current runtime state of the micro-VM.
    pub fn is_vm_active(&self) -> bool {
        self.active_vm_state
    }

    /// Computes hardware-accelerated cosine similarity across two floating-point slices.
    pub fn cosine_similarity(a: &[f32], b: &[f32]) -> f32 {
        if a.len() != b.len() || a.is_empty() {
            return 0.0;
        }

        let start = Instant::now();
        let dot = Self::dot_product_slice(a, b);
        let norm_a = Self::dot_product_slice(a, a).sqrt();
        let norm_b = Self::dot_product_slice(b, b).sqrt();
        let elapsed = start.elapsed().as_secs_f64();

        if elapsed > 0.0 {
            let throughput = (a.len() as f64) / elapsed;
            GLOBAL_VECTOR_THROUGHPUT.store(throughput.to_bits(), Ordering::Relaxed);
        }

        if norm_a == 0.0 || norm_b == 0.0 {
            return 0.0;
        }

        dot / (norm_a * norm_b)
    }

    /// ARM64 NEON optimized dot-product calculation.
    #[cfg(target_arch = "aarch64")]
    pub fn dot_product_slice(a: &[f32], b: &[f32]) -> f32 {
        let len = a.len();
        let mut i = 0;
        let sum_val;

        unsafe {
            let mut acc = vdupq_n_f32(0.0);
            while i + 3 < len {
                let va = vld1q_f32(a.as_ptr().add(i));
                let vb = vld1q_f32(b.as_ptr().add(i));
                acc = vfmaq_f32(acc, va, vb);
                i += 4;
            }

            let temp: [f32; 4] = [
                vgetq_lane_f32(acc, 0),
                vgetq_lane_f32(acc, 1),
                vgetq_lane_f32(acc, 2),
                vgetq_lane_f32(acc, 3),
            ];
            sum_val = temp[0] + temp[1] + temp[2] + temp[3];
        }

        let mut total = sum_val;
        while i < len {
            total += a[i] * b[i];
            i += 1;
        }

        total
    }

    /// Fallback standard dot-product calculation for non-ARM64 architectures.
    #[cfg(not(target_arch = "aarch64"))]
    pub fn dot_product_slice(a: &[f32], b: &[f32]) -> f32 {
        a.iter().zip(b.iter()).map(|(x, y)| x * y).sum()
    }

    /// Executes a reference SIMD vector benchmark pass for live UI telemetry.
    pub fn run_benchmark_pass() -> f32 {
        let reference_a = vec![1.0, 0.5, 0.3, 0.9, 1.0, 0.5, 0.3, 0.9];
        let reference_b = vec![0.9, 0.4, 0.2, 0.8, 0.9, 0.4, 0.2, 0.8];
        Self::cosine_similarity(&reference_a, &reference_b)
    }

    /// Fetches the last recorded vector throughput value atomically.
    pub fn get_last_throughput() -> f64 {
        f64::from_bits(GLOBAL_VECTOR_THROUGHPUT.load(Ordering::Relaxed))
    }
}
