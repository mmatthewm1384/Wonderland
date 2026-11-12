import XCTest

@MainActor
final class PlaybackControlStateTests: XCTestCase {
    func testPlaybackControlStateInitialization() {
        let state = PlaybackControlState()
        XCTAssertNotNil(state, "PlaybackControlState should instantiate successfully.")
    }
}
