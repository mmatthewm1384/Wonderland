import Foundation

public final class AIEphemeralContext {
    private let sparkBuffer: VolatileSparkBuffer
    public let sessionID: UUID
    private var isFinalized: Bool = false

    public init(capacityBytes: Int) {
        self.sessionID = UUID()
        // Allocates a dedicated 64-byte aligned ephemeral buffer via VolatileSparkBuffer
        self.sparkBuffer = VolatileSparkBuffer(byteCount: capacityBytes)
    }

    /// Write prompt or attention state data directly into the secure cache-aligned buffer
    public func writeContext(from data: Data) -> Bool {
        guard !self.isFinalized else { return false }

        return data.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else { return false }
            let bytesToWrite = min(data.count, self.sparkBuffer.byteCount)

            // Copy into the 64-byte aligned pointer
            self.sparkBuffer.pointer.copyMemory(from: baseAddress, byteCount: bytesToWrite)
            return true
        }
    }

    /// Read raw pointer for SIMD/vDSP vector engines or inference passes
    public var rawContextPointer: UnsafeMutableRawPointer {
        self.sparkBuffer.pointer
    }

    /// Finalize session and instantly wipe all volatile data from memory
    public func finalizeSession() {
        guard !self.isFinalized else { return }
        self.sparkBuffer.wipe()
        self.isFinalized = true
    }

    deinit {
        finalizeSession()
    }
}
