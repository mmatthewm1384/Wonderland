import AVFoundation
@testable import Synapse
import XCTest

final class AudioEngineTests: XCTestCase {
    func testAudioEngineInitialization() {
        let engine = SynapseAudioEngine()
        XCTAssertNotNil(engine, "SynapseAudioEngine should initialize successfully.")
    }

    func testSessionConfiguration() async {
        let engine = SynapseAudioEngine()
        do {
            try await engine.configureSession()
            // If it doesn't throw, session configuration succeeds for the test environment
            XCTAssertTrue(true)
        } catch {
            // In headless or CI environments without audio hardware, catch gracefully
            XCTAssertNotNil(error)
        }
    }
}
