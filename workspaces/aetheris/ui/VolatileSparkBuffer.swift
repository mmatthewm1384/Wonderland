import Foundation

public final class VolatileSparkBuffer {
    public private(set) var byteCount: Int
    public private(set) var pointer: UnsafeMutableRawPointer
    private var isDisposed: Bool = false

    public init(byteCount: Int) {
        self.byteCount = byteCount
        // Allocate zero-initialized memory aligned to 64-byte cache line boundaries
        let alignment = 64
        self.pointer = UnsafeMutableRawPointer.allocate(
            byteCount: byteCount,
            alignment: alignment
        )
        self.pointer.initializeMemory(as: UInt8.self, repeating: 0, count: byteCount)
    }

    /// Securely scrub memory contents before deallocation
    public func wipe() {
        guard !self.isDisposed else { return }

        // Invoke the high-speed Rust volatile zeroizer via the FFI bridge
        WonderlandFFI.sanitizeEphemeralBuffer(self.pointer, self.byteCount)

        self.isDisposed = true
    }

    deinit {
        if !isDisposed {
            wipe()
        }
        pointer.deallocate()
    }
}
