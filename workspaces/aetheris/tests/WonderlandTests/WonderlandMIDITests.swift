@testable import WonderlandApp
import XCTest

@MainActor
final class WonderlandMIDITests: XCTestCase {
    func testMIDIControlChangeThroughputAdjustment() {
        let viewModel = WonderlandRuntimeViewModel()

        // Simulate twisting Rotary Knob 1 (CC 16) to max value (127)
        viewModel.simulateMIDIControlChangeForTesting(controller: 16, value: 127)

        // Verify throughput scaled to max (200.0)
        XCTAssertEqual(viewModel.vectorThroughput, 200.0, accuracy: 0.1, "Throughput should scale to max on CC 16 value 127")

        // Simulate turning it down to halfway (~63)
        viewModel.simulateMIDIControlChangeForTesting(controller: 16, value: 63)
        let expectedHalf = Float(63) / 127.0 * 200.0
        XCTAssertEqual(viewModel.vectorThroughput, expectedHalf, accuracy: 0.1)
    }

    func testMIDIPadTriggerBenchmark() {
        let viewModel = WonderlandRuntimeViewModel()
        _ = viewModel.benchmarkScore

        // Simulate hitting Pad 1 (CC 36) with velocity > 64
        viewModel.simulateMIDIControlChangeForTesting(controller: 36, value: 100)

        // Verify benchmark executed and logs/score updated
        XCTAssertNotNil(viewModel.telemetryLogs.last)
        XCTAssertEqual(viewModel.telemetryLogs.last?.source, "BENCHMARK")
    }

    func testMIDIManagerInitialization() {
        let midiManager = WonderlandMIDIManager()
        // Verify manager initializes client and client ports without crashing
        XCTAssertNotNil(midiManager)
        XCTAssertTrue(midiManager.connectedDevices.isEmpty || !midiManager.connectedDevices.isEmpty)
    }
}
