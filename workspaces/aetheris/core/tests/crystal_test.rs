use wonderland_core::crystal::MemoryCrystal;

#[test]
fn test_memory_crystal_roundtrip_and_verification() {
    let scores = vec![0.85, 0.98, 0.42, 0.91];
    let threshold = 0.90;
    let timestamp = 1788470340;

    let crystal = MemoryCrystal::seal_vector_intersections(&scores, threshold, timestamp)
        .expect("Failed to seal crystal");

    assert!(crystal.verify(), "Crystal signature verification failed");

    // Test roundtrip via deserialize_from_bytes
    let deserialized = MemoryCrystal::deserialize_from_bytes(&crystal.payload)
        .expect("Failed to deserialize crystal from bytes");

    assert!(deserialized.verify(), "Deserialized crystal failed verification");

    // Verify zero-copy inspection reads the correct data
    crystal.inspect_matches(|archived_cache| {
        assert_eq!(archived_cache.query_timestamp, timestamp);
        assert_eq!(archived_cache.threshold, threshold);
        assert_eq!(archived_cache.matches.len(), 2); // 0.98 and 0.91
    }).expect("Failed to inspect matches");
}

#[test]
fn test_memory_crystal_tamper_detection() {
    let scores = vec![0.95, 0.88, 0.99];
    let threshold = 0.90;
    let timestamp = 1788470340;

    let mut crystal = MemoryCrystal::seal_vector_intersections(&scores, threshold, timestamp)
        .expect("Failed to seal crystal");

    assert!(crystal.verify());

    // Tamper with the payload bytes
    if let Some(byte) = crystal.payload.first_mut() {
        *byte ^= 0xFF;
    }

    assert!(!crystal.verify(), "Tampered crystal should fail verification");
}
