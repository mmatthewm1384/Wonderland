import Foundation

// MARK: - Private C-Compatible FFI Symbols

@_silgen_name("wonderland_verify_crystal")
private func _verifyCrystal(_ dataPtr: UnsafePointer<UInt8>, _ dataLen: Int) -> Bool

@_silgen_name("wonderland_trigger_benchmark")
private func _triggerBenchmark() -> Float

@_silgen_name("wonderland_spawn_vm")
private func _spawnVM() -> Bool

@_silgen_name("wonderland_get_last_vector_throughput")
private func _getLastVectorThroughput() -> Float

@_silgen_name("wonderland_sanitize_ephemeral_buffer")
private func _sanitizeEphemeralBuffer(_ ptr: UnsafeMutableRawPointer, _ len: Int)

@_silgen_name("wonderland_cosine_similarity")
private func _cosineSimilarity(
    _ aPtr: UnsafePointer<Float>, _ aLen: Int,
    _ bPtr: UnsafePointer<Float>, _ bLen: Int
) -> Float

// MARK: - WonderlandFFI Namespace

public enum WonderlandFFI {
    public static func verifyCrystal(_ dataPtr: UnsafePointer<UInt8>, _ dataLen: Int) -> Bool {
        _verifyCrystal(dataPtr, dataLen)
    }

    public static func triggerBenchmark() -> Float {
        _triggerBenchmark()
    }

    public static func spawnVM() -> Bool {
        _spawnVM()
    }

    public static func getLastVectorThroughput() -> Float {
        _getLastVectorThroughput()
    }

    public static func sanitizeEphemeralBuffer(_ ptr: UnsafeMutableRawPointer, _ len: Int) {
        _sanitizeEphemeralBuffer(ptr, len)
    }

    /// Safe wrapper for cosine similarity with automatic pointer validation and bounds checking
    public static func safeCosineSimilarity(vectorA: [Float], vectorB: [Float]) -> Float {
        guard !vectorA.isEmpty, !vectorB.isEmpty, vectorA.count == vectorB.count else {
            return 0.0
        }

        return vectorA.withUnsafeBufferPointer { aBuffer in
            vectorB.withUnsafeBufferPointer { bBuffer in
                guard let aPtr = aBuffer.baseAddress, let bPtr = bBuffer.baseAddress else {
                    return 0.0
                }
                return _cosineSimilarity(aPtr, vectorA.count, bPtr, vectorB.count)
            }
        }
    }
}
