import Accelerate
import Foundation

// MARK: - C-FFI Function Declarations matching src/ffi.rs

@_silgen_name("wonderland_cosine_similarity")
func wonderland_cosine_similarity(
    _ aPtr: UnsafePointer<Float>,
    _ aLen: Int,
    _ bPtr: UnsafePointer<Float>,
    _ bLen: Int
) -> Float

@_silgen_name("wonderland_verify_and_inspect_crystal")
func wonderland_verify_and_inspect_crystal(
    _ payloadPtr: UnsafePointer<UInt8>,
    _ payloadLen: Int,
    _ matchCountOut: UnsafeMutablePointer<Int>
) -> Bool

@_silgen_name("wonderland_trigger_benchmark")
func wonderland_trigger_benchmark() -> Float

@_silgen_name("wonderland_get_last_vector_throughput")
func wonderland_get_last_vector_throughput() -> Float

@_silgen_name("wonderland_spawn_vm")
func wonderland_spawn_vm() -> Bool

// MARK: - Wonderland Vector Engine Wrapper

public class WonderlandVectorEngine {
    public init() {}

    public func cosineSimilarity(a: [Float], b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0.0 }
        return a.withUnsafeBufferPointer { aBuf in
            b.withUnsafeBufferPointer { bBuf in
                wonderland_cosine_similarity(aBuf.baseAddress!, a.count, bBuf.baseAddress!, b.count)
            }
        }
    }

    public func acceleratedCosineSimilarity(a: [Float], b: [Float]) -> Float {
        var dotProduct: Float = 0.0
        var normA: Float = 0.0
        var normB: Float = 0.0

        vDSP_dotpr(a, 1, b, 1, &dotProduct, vDSP_Length(a.count))
        vDSP_svesq(a, 1, &normA, vDSP_Length(a.count))
        vDSP_svesq(b, 1, &normB, vDSP_Length(b.count))

        let denominator = sqrt(normA) * sqrt(normB)
        guard denominator > 0 else { return 0.0 }
        return dotProduct / denominator
    }

    public func batchCosineSimilarity(queries: [[Float]], target: [Float]) -> [Float] {
        let chunkSize = 16
        var results: [Float] = []
        results.reserveCapacity(queries.count)

        // Process queries in optimized chunks
        let chunks = stride(from: 0, to: queries.count, by: chunkSize).map {
            Array(queries[$0 ..< min($0 + chunkSize, queries.count)])
        }

        for chunk in chunks {
            for query in chunk {
                let similarity = self.acceleratedCosineSimilarity(a: query, b: target)
                results.append(similarity)
            }
        }

        return results
    }

    public func verifyCrystal(payload: Data) -> (isValid: Bool, matchCount: Int) {
        var matchCount = 0
        let isValid = payload.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return false
            }
            return wonderland_verify_and_inspect_crystal(baseAddress, payload.count, &matchCount)
        }
        return (isValid, matchCount)
    }

    public func triggerBenchmark() -> Float {
        wonderland_trigger_benchmark()
    }

    public func getLastThroughput() -> Float {
        wonderland_get_last_vector_throughput()
    }
}
