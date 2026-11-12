use wonderland_core::vector::VectorEngine;

#[test]
fn test_vector_cosine_similarity() {
    let v1 = vec![1.0, 0.0, 0.0, 1.0];
    let v2 = vec![1.0, 0.0, 0.0, 1.0];
    let v3 = vec![0.0, 1.0, 1.0, 0.0];

    let sim_identical = VectorEngine::cosine_similarity(&v1, &v2);
    assert!((sim_identical - 1.0).abs() < 1e-5, "Identical vectors should have cosine similarity ~1.0");

    let sim_orthogonal = VectorEngine::cosine_similarity(&v1, &v3);
    assert!(sim_orthogonal.abs() < 1e-5, "Orthogonal vectors should have cosine similarity ~0.0");
}
