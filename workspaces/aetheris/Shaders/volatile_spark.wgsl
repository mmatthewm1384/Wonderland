struct EphemeralHeader {
    magic: u32,
    stateFlags: u32,
    bufferSize: u32,
    entropySeed: u32,
};

@group(0) @binding(0) var<storage, read_write> memoryBuffer: array<u32>;
@group(0) @binding(1) var<uniform> header: EphemeralHeader;

// PCG Hash for deterministic pseudo-random scrambling during sanitization
fn pcg_hash(input: u32) -> u32 {
    let state = input * 747796405u + 2891336453u;
    let word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

@compute @workgroup_size(256)
fn main(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let index = global_id.x;
    if (index >= header.bufferSize) {
        return;
    }

    let mode = header.stateFlags & 0x03u;

    if (mode == 0x01u) {
        // Mode 1: Secure Zeroization (Zero-fill for disposal)
        memoryBuffer[index] = 0u;
    } else if (mode == 0x02u) {
        // Mode 2: Entropic Scramble (Overwriting with cryptographic noise before release)
        let seed = header.entropySeed ^ index;
        memoryBuffer[index] = pcg_hash(seed);
    } else {
        // Mode 3: Passthrough / Active State Compute
        // No-op or custom ephemeral transform
        memoryBuffer[index] = memoryBuffer[index] ^ header.entropySeed;
    }
}
