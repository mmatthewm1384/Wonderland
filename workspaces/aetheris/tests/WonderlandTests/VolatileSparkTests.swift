import Metal
@testable import WonderlandApp
import XCTest

@available(macOS 14.0, *)
final class VolatileSparkTests: XCTestCase {
    func testVolatileSparkInitialization() {
        guard MTLCreateSystemDefaultDevice() != nil else {
            print("Skipping VolatileSpark test: Metal device not available in this environment.")
            return
        }

        do {
            let manager = try VolatileSparkManager()
            XCTAssertNotNil(manager, "VolatileSparkManager should initialize successfully when Metal is available.")
        } catch {
            XCTFail("Failed to initialize VolatileSparkManager: \(error)")
        }
    }

    func testZeroizationSanitization() {
        guard MTLCreateSystemDefaultDevice() != nil else { return }

        do {
            let manager = try VolatileSparkManager()
            var buffer: [UInt32] = [0x1234_5678, 0xABCD_EF01, 0x8765_4321, 0xFEDC_BA98]

            let success = manager.executeSanitization(on: &buffer, mode: .zeroize)
            XCTAssertTrue(success, "Sanitization execution should succeed.")

            for val in buffer {
                XCTAssertEqual(val, 0, "All elements should be zeroized after zeroize mode execution.")
            }
        } catch {
            XCTFail("Initialization or execution failed: \(error)")
        }
    }

    func testEntropicScrambleSanitization() {
        guard MTLCreateSystemDefaultDevice() != nil else { return }

        do {
            let manager = try VolatileSparkManager()
            let originalBuffer: [UInt32] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            var buffer = originalBuffer

            let success = manager.executeSanitization(on: &buffer, mode: .entropicScramble, entropySeed: 1337)
            XCTAssertTrue(success, "Entropic scrambling execution should succeed.")

            // Verify that the buffer was successfully scrambled by the compute shader
            XCTAssertNotEqual(buffer, originalBuffer, "Buffer contents should be transformed by the entropy shader.")
        } catch {
            XCTFail("Initialization or execution failed: \(error)")
        }
    }
}
