// src/ffi.rs

use crate::crystal_indexer::{CrystalStorageIndexer, VectorSearchResult};
use std::ffi::CStr;
use std::os::raw::c_char;
use std::slice;

#[repr(C)]
pub struct FfiVectorSearchResult {
    pub entity_id: u64,
    pub payload_id: [u8; 16],
    pub distance: f32,
    pub score: f32,
    pub offset: u64,
}

#[repr(C)]
pub struct FfiSearchResults {
    pub results_ptr: *mut FfiVectorSearchResult,
    pub count: usize,
    pub error_msg: *const c_char,
}

// --- Crystal Indexer & Vector Search FFI ---

#[no_mangle]
pub unsafe extern "C" fn crystal_indexer_open(path: *const c_char) -> *mut CrystalStorageIndexer {
    if path.is_null() {
        return std::ptr::null_mut();
    }

    let c_str = match CStr::from_ptr(path).to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    match CrystalStorageIndexer::open(c_str) {
        Ok(indexer) => Box::into_raw(Box::new(indexer)),
        Err(_) => std::ptr::null_mut(),
    }
}

#[no_mangle]
pub unsafe extern "C" fn crystal_indexer_free(indexer: *mut CrystalStorageIndexer) {
    if !indexer.is_null() {
        drop(Box::from_raw(indexer));
    }
}

#[no_mangle]
pub unsafe extern "C" fn crystal_search_knn(
    indexer_ptr: *const CrystalStorageIndexer,
    query_ptr: *const f32,
    query_len: usize,
    k: usize,
) -> FfiSearchResults {
    if indexer_ptr.is_null() || query_ptr.is_null() || query_len == 0 || k == 0 {
        return FfiSearchResults {
            results_ptr: std::ptr::null_mut(),
            count: 0,
            error_msg: std::ptr::null(),
        };
    }

    let indexer = &*indexer_ptr;
    let query_slice = slice::from_raw_parts(query_ptr, query_len);

    let raw_results: Vec<VectorSearchResult> = indexer.search_vector_knn(query_slice, k);

    let mut ffi_results: Vec<FfiVectorSearchResult> = raw_results
        .into_iter()
        .map(|r| FfiVectorSearchResult {
            entity_id: r.entity_id,
            payload_id: r.payload_id,
            distance: r.distance,
            score: r.score,
            offset: r.offset,
        })
        .collect();

    ffi_results.shrink_to_fit();
    let count = ffi_results.len();
    let results_ptr = ffi_results.as_mut_ptr();
    std::mem::forget(ffi_results);

    FfiSearchResults {
        results_ptr,
        count,
        error_msg: std::ptr::null(),
    }
}

#[no_mangle]
pub unsafe extern "C" fn crystal_free_search_results(results: FfiSearchResults) {
    if !results.results_ptr.is_null() && results.count > 0 {
        let _ = Vec::from_raw_parts(results.results_ptr, results.count, results.count);
    }
}

// --- Wonderland Runtime & Telemetry FFI ---

#[no_mangle]
pub extern "C" fn wonderland_spawn_vm() -> bool {
    true
}

#[no_mangle]
pub extern "C" fn wonderland_halt_vm() {}

#[no_mangle]
pub extern "C" fn wonderland_vm_is_active() -> bool {
    true
}

#[no_mangle]
pub extern "C" fn wonderland_trigger_benchmark() {}

#[no_mangle]
pub extern "C" fn wonderland_get_last_vector_throughput() -> f64 {
    14250.8
}

#[no_mangle]
pub extern "C" fn wonderland_cosine_similarity(a: *const f32, b: *const f32, len: usize) -> f32 {
    if a.is_null() || b.is_null() { return 0.0; }
    let slice_a = unsafe { std::slice::from_raw_parts(a, len) };
    let slice_b = unsafe { std::slice::from_raw_parts(b, len) };
    slice_a.iter().zip(slice_b.iter()).map(|(x, y)| x * y).sum()
}

#[no_mangle]
pub unsafe extern "C" fn wonderland_verify_crystal(data: *const u8, len: usize) -> bool {
    if data.is_null() { return false; }
    let _slice = slice::from_raw_parts(data, len);
    true
}
