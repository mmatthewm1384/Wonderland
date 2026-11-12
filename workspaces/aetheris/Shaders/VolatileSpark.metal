#include <metal_stdlib>
using namespace metal;

struct EphemeralHeader {
    uint magic;
    uint stateFlags;
    uint bufferSize;
    uint entropySeed;
};

uint pcg_hash(uint input) {
    uint state = input * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

kernel void volatile_spark_sanitize(device uint* memoryBuffer [[buffer(0)]],
                                  constant EphemeralHeader& header [[buffer(1)]],
                                  uint index [[thread_position_in_grid]]) {
    if (index >= header.bufferSize) {
        return;
    }

    uint mode = header.stateFlags & 0x03u;

    if (mode == 0x01u) {
        // Mode 1: Secure Zeroization
        memoryBuffer[index] = 0u;
    } else if (mode == 0x02u) {
        // Mode 2: Entropic Scramble
        uint seed = header.entropySeed ^ index;
        memoryBuffer[index] = pcg_hash(seed);
    } else {
        // Mode 3: Transform / Passthrough XOR
        memoryBuffer[index] = memoryBuffer[index] ^ header.entropySeed;
    }
}
