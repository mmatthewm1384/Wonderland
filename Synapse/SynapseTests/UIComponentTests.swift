import SwiftUI
import XCTest

@MainActor
final class UIComponentTests: XCTestCase {
    func testWaveformVisualizerInstantiationAndHosting() {
        let sampleData: [Float] = [0.1, 0.4, 0.8, 0.5, 0.2]
        let visualizer = WaveformVisualizer(samples: sampleData)
        XCTAssertNotNil(visualizer, "WaveformVisualizer should instantiate successfully with sample data.")

        let hostingController = NSHostingController(rootView: visualizer)
        XCTAssertNotNil(hostingController.view, "NSHostingController should successfully host WaveformVisualizer view.")
    }

    func testPlaybackControlViewInstantiationAndHosting() {
        let state = PlaybackControlState()
        let controlView = PlaybackControlView(controlState: state)
        XCTAssertNotNil(controlView, "PlaybackControlView should instantiate with control state successfully.")

        let hostingController = NSHostingController(rootView: controlView)
        XCTAssertNotNil(hostingController.view, "NSHostingController should successfully host PlaybackControlView.")
    }
}
