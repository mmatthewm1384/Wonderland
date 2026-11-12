use std::ffi::CStr;
use std::os::raw::{c_char, c_int, c_uint, c_void};

use crate::crystal::MemoryCrystal;
use crate::vector::VectorEngine;

/// Opaque handle wrapper for VectorEngine.
pub struct FfiVectorEngine {
    inner: VectorEngine,
}

/// Creates a vector engine.
///
/// Returns an owned opaque handle. The caller must release it with
/// `wonderland_vector_engine_free`.
#[no_mangle]
pub extern "C" fn wonderland_vector_engine_new(
    dimension: c_uint,
) -> *mut FfiVectorEngine {
    if dimension == 0 {
        return std::ptr::null_mut();
    }

    let engine = VectorEngine {
        dimension: dimension as usize,
        corpus: Vec::new(),
    };

    Box::into_raw(Box::new(FfiVectorEngine { inner: engine }))
}

/// Releases a handle created by `wonderland_vector_engine_new`.
///
/// # Safety
/// `ptr` must be null or a valid, live handle returned by
/// `wonderland_vector_engine_new`, not previously freed.
#[no_mangle]
pub unsafe extern "C" fn wonderland_vector_engine_free(
    ptr: *mut FfiVectorEngine,
) {
    if !ptr.is_null() {
        unsafe {
            drop(Box::from_raw(ptr));
        }
    }
}

/// Adds one vector to the engine.
///
/// # Safety
/// - `ptr` must be a valid, exclusively accessible engine handle.
/// - `data` must reference at least `len` readable `f32` values.
/// - The memory referenced by `data` must remain valid for this call.
#[no_mangle]
pub unsafe extern "C" fn wonderland_vector_engine_add(
    ptr: *mut FfiVectorEngine,
    data: *const f32,
    len: c_uint,
) -> c_int {
    if ptr.is_null() || data.is_null() || len == 0 {
        return 0;
    }

    let engine = unsafe { &mut *ptr };
    let values = unsafe {
        std::slice::from_raw_parts(data, len as usize)
    };

    match engine.inner.add_vector(values.to_vec()) {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

/// Computes cosine similarity between two equal-length vectors.
///
/// Returns `0.0` for null pointers, empty vectors, or mismatched lengths.
///
/// # Safety
/// - `a_ptr` must reference `a_len` readable `f32` values.
/// - `b_ptr` must reference `b_len` readable `f32` values.
/// - Both buffers must remain valid for this call.
#[no_mangle]
pub unsafe extern "C" fn wonderland_cosine_similarity(
    a_ptr: *const f32,
    a_len: usize,
    b_ptr: *const f32,
    b_len: usize,
) -> f32 {
    if a_ptr.is_null()
        || b_ptr.is_null()
        || a_len == 0
        || a_len != b_len
    {
        return 0.0;
    }

    let a = unsafe {
        std::slice::from_raw_parts(a_ptr, a_len)
    };
    let b = unsafe {
        std::slice::from_raw_parts(b_ptr, b_len)
    };

    VectorEngine::cosine_similarity(a, b)
}

/// Validates that the supplied bytes contain a structurally valid Crystal archive.
///
/// This validates archive structure; it does not authenticate the publisher.
///
/// # Safety
/// `data_ptr` must reference `data_len` readable bytes.
#[no_mangle]
pub unsafe extern "C" fn wonderland_verify_crystal(
    data_ptr: *const u8,
    data_len: usize,
) -> bool {
    if data_ptr.is_null() || data_len == 0 {
        return false;
    }

    let payload = unsafe {
        std::slice::from_raw_parts(data_ptr, data_len)
    };

    MemoryCrystal::deserialize_from_bytes(payload).is_ok()
}

/// Validates a Crystal archive and returns its intersection count.
///
/// This checks archive structure and reads the match count. It does not
/// authenticate the original publisher or establish provenance.
///
/// # Safety
/// - `data_ptr` must reference `data_len` readable bytes.
/// - `match_count_out` must reference writable, properly aligned storage
///   for one `usize`.
/// - The output storage must not overlap the input buffer.
#[no_mangle]
pub unsafe extern "C" fn wonderland_verify_and_inspect_crystal(
    data_ptr: *const u8,
    data_len: usize,
    match_count_out: *mut usize,
) -> bool {
    if match_count_out.is_null() {
        return false;
    }

    unsafe {
        *match_count_out = 0;
    }

    if data_ptr.is_null() || data_len == 0 {
        return false;
    }

    let payload = unsafe {
        std::slice::from_raw_parts(data_ptr, data_len)
    };

    let Ok(crystal) = MemoryCrystal::deserialize_from_bytes(payload) else {
        return false;
    };

    let Ok(match_count) = crystal.inspect_matches(|archived| {
        archived.matches.len()
    }) else {
        return false;
    };

    unsafe {
        *match_count_out = match_count;
    }

    true
}

/// Placeholder benchmark value.
///
/// This is not a measured benchmark result.
#[no_mangle]
pub extern "C" fn wonderland_trigger_benchmark() -> f32 {
    948.5
}

/// Placeholder VM status.
///
/// This does not spawn or verify a VM.
#[no_mangle]
pub extern "C" fn wonderland_spawn_vm() -> bool {
    true
}

/// Placeholder throughput value.
///
/// This is not measured runtime telemetry.
#[no_mangle]
pub extern "C" fn wonderland_get_last_vector_throughput() -> f32 {
    1250.75
}

/// Zeroes a caller-provided buffer.
///
/// # Safety
/// If `len` is greater than zero, `ptr` must reference at least `len`
/// writable bytes.
#[no_mangle]
pub unsafe extern "C" fn wonderland_sanitize_ephemeral_buffer(
    ptr: *mut c_void,
    len: usize,
) {
    if !ptr.is_null() && len > 0 {
        unsafe {
            std::ptr::write_bytes(ptr, 0, len);
        }
    }
}

/// Verifies a Crystal payload against a caller-provided BLAKE3 digest.
///
/// The digest is an unkeyed hash. It detects payload changes relative to
/// the supplied digest but does not authenticate who supplied that digest.
///
/// # Safety
/// - `payload_ptr` must reference `payload_len` readable bytes.
/// - `signature_ptr` must point to a valid NUL-terminated C string.
/// - Both pointers must remain valid for this call.
#[no_mangle]
pub unsafe extern "C" fn wonderland_crystal_verify_raw(
    payload_ptr: *const u8,
    payload_len: c_uint,
    signature_ptr: *const c_char,
) -> c_int {
    if payload_ptr.is_null()
        || signature_ptr.is_null()
        || payload_len == 0
    {
        return 0;
    }

    let payload = unsafe {
        std::slice::from_raw_parts(
            payload_ptr,
            payload_len as usize,
        )
    };

    let c_str = unsafe {
        CStr::from_ptr(signature_ptr)
    };

    let Ok(signature) = c_str.to_str() else {
        return 0;
    };

    let crystal = MemoryCrystal {
        id: uuid::Uuid::nil(),
        payload: payload.to_vec(),
        signature: signature.to_string(),
    };

    if crystal.verify() {
        1
    } else {
        0
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample_crystal() -> MemoryCrystal {
        MemoryCrystal::seal_vector_intersections(
            &[0.85, 0.98, 0.42, 0.91],
            0.90,
            1_788_470_340,
        )
        .expect("sample Crystal should serialize")
    }

    #[test]
    fn ffi_inspection_returns_actual_match_count() {
        let crystal = sample_crystal();
        let mut count = usize::MAX;

        let result = unsafe {
            wonderland_verify_and_inspect_crystal(
                crystal.payload.as_ptr(),
                crystal.payload.len(),
                &mut count,
            )
        };

        assert!(result);
        assert_eq!(count, 2);
    }

    #[test]
    fn ffi_inspection_rejects_truncated_archive() {
        let crystal = sample_crystal();
        let mut corrupted = crystal.payload.clone();
        corrupted.truncate(corrupted.len() / 2);

        let mut count = usize::MAX;

        let result = unsafe {
            wonderland_verify_and_inspect_crystal(
                corrupted.as_ptr(),
                corrupted.len(),
                &mut count,
            )
        };

        assert!(!result);
        assert_eq!(count, 0);
    }

    #[test]
    fn ffi_inspection_rejects_null_payload() {
        let mut count = usize::MAX;

        let result = unsafe {
            wonderland_verify_and_inspect_crystal(
                std::ptr::null(),
                10,
                &mut count,
            )
        };

        assert!(!result);
        assert_eq!(count, 0);
    }

    #[test]
    fn ffi_inspection_rejects_null_output() {
        let result = unsafe {
            wonderland_verify_and_inspect_crystal(
                std::ptr::null(),
                0,
                std::ptr::null_mut(),
            )
        };

        assert!(!result);
    }

    #[test]
    fn verify_crystal_rejects_invalid_archive() {
        let invalid = [0_u8; 16];

        let result = unsafe {
            wonderland_verify_crystal(
                invalid.as_ptr(),
                invalid.len(),
            )
        };

        assert!(!result);
    }
}
