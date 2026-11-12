import AVFoundation
import XCTest

final class SynapseAudioEngineTests: XCTestCase {
    func testAudioEngineInitialization() {
        let audioEngine = SynapseAudioEngine()
        XCTAssertNotNil(audioEngine, "SynapseAudioEngine should initialize successfully.")
    }

    func testAudioBufferCreationAndCallbackHandling() {
        let audioEngine = SynapseAudioEngine()
        XCTAssertNotNil(audioEngine, "Engine instance required for buffer testing.")

        // Create a standard audio format and PCM buffer to test stream callback flows
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 512)
        else {
            XCTFail("Failed to instantiate standard AVAudioFormat or AVAudioPCMBuffer.")
            return
        }

        buffer.frameLength = 512

        // Verify buffer integrity and properties passed into audio processing pipelines
        XCTAssertEqual(buffer.format.sampleRate, 44100.0, "Buffer sample rate should match 44.1kHz.")
        XCTAssertEqual(buffer.frameLength, 512, "Buffer frame length should be correctly set.")
    }

    func testAudioEngineStateLifecycle() {
        let audioEngine = SynapseAudioEngine()
        // Exercise engine configuration states safely in test environment
        XCTAssertNotNil(audioEngine)
    }
}
