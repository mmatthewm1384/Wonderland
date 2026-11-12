import Foundation
import Metal

@available(macOS 14.0, *)
public class VolatileSparkManager: NSObject {
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    private var computePipelineState: MTLComputePipelineState?
    private var isFallbackMode: Bool = false

    public enum SanitizationMode: UInt32 {
        case zeroize = 0x01
        case entropicScramble = 0x02
        case transform = 0x03
    }

    override public init() {
        super.init()
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            self.isFallbackMode = true
            return
        }
        self.device = defaultDevice
        self.commandQueue = defaultDevice.makeCommandQueue()
        do {
            try self.setupComputePipeline(device: defaultDevice)
        } catch {
            // Fallback to CPU mode if Metal library is missing (e.g., in test bundles)
            self.isFallbackMode = true
        }
    }

    private func setupComputePipeline(device: MTLDevice) throws {
        let bundle = Bundle(for: type(of: self))
        let library: MTLLibrary
        do {
            library = try device.makeDefaultLibrary(bundle: bundle)
        } catch {
            guard let fallbackLib = device.makeDefaultLibrary() else {
                throw NSError(domain: "VolatileSpark", code: 5002, userInfo: [NSLocalizedDescriptionKey: "Failed to load default Metal library."])
            }
            library = fallbackLib
        }

        guard let kernelFunction = library.makeFunction(name: "volatile_spark_sanitize") else {
            throw NSError(domain: "VolatileSpark", code: 5003, userInfo: [NSLocalizedDescriptionKey: "Failed to locate kernel function."])
        }
        self.computePipelineState = try device.makeComputePipelineState(function: kernelFunction)
    }

    public func executeSanitization(on buffer: inout [UInt32], mode: SanitizationMode, entropySeed: UInt32 = 0xDEAD_BEEF) -> Bool {
        if self.isFallbackMode {
            // CPU-based fallback for testing environments and non-Metal hosts
            switch mode {
            case .zeroize:
                for i in 0 ..< buffer.count {
                    buffer[i] = 0
                }
            case .entropicScramble, .transform:
                let seed = entropySeed
                for i in 0 ..< buffer.count {
                    buffer[i] = buffer[i] ^ seed ^ UInt32(i)
                }
            }
            return true
        }

        guard let device,
              let commandQueue,
              let pipelineState = computePipelineState
        else {
            return false
        }

        let count = buffer.count
        let byteSize = count * MemoryLayout<UInt32>.size

        guard let mtlBuffer = device.makeBuffer(bytes: &buffer, length: byteSize, options: .storageModeShared) else {
            return false
        }

        var header = (
            magic: UInt32(0x5653_504B),
            stateFlags: mode.rawValue,
            bufferSize: UInt32(count),
            entropySeed: entropySeed
        )

        guard let headerBuffer = device.makeBuffer(bytes: &header, length: MemoryLayout.size(ofValue: header), options: .storageModeShared),
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder()
        else {
            return false
        }

        encoder.setComputePipelineState(pipelineState)
        encoder.setBuffer(mtlBuffer, offset: 0, index: 0)
        encoder.setBuffer(headerBuffer, offset: 0, index: 1)

        let threadGroupSize = MTLSize(width: 256, height: 1, depth: 1)
        let threadGroups = MTLSize(width: (count + 255) / 256, height: 1, depth: 1)

        encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        let pointer = mtlBuffer.contents().bindMemory(to: UInt32.self, capacity: count)
        buffer = Array(UnsafeBufferPointer(start: pointer, count: count))

        return true
    }
}
