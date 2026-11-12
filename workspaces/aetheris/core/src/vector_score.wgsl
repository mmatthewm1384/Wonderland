struct Uniforms {
    vector_dim: u32,
    num_vectors: u32,
};

@group(0) @binding(0) var<uniform> uniforms: Uniforms;
@group(0) @binding(1) var<storage, read> query: array<f32>;
@group(0) @binding(2) var<storage, read> database: array<f32>;
@group(0) @binding(3) var<storage, read_write> scores: array<f32>;

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let index = global_id.x;
    if (index >= uniforms.num_vectors) {
        return;
    }

    let dim = uniforms.vector_dim;
    let base_offset = index * dim;

    var dot_product: f32 = 0.0;
    var norm_query: f32 = 0.0;
    var norm_db: f32 = 0.0;

    for (var i: u32 = 0u; i < dim; i = i + 1u) {
        let q = query[i];
        let d = database[base_offset + i];

        dot_product = dot_product + (q * d);
        norm_query = norm_query + (q * q);
        norm_db = norm_db + (d * d);
    }

    let denominator = sqrt(norm_query) * sqrt(norm_db);
    if (denominator == 0.0) {
        scores[index] = 0.0;
    } else {
        scores[index] = dot_product / denominator;
    }
}
