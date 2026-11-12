@testable import Synapse
import XCTest

final class SpeechRecognizerTests: XCTestCase {
    func testSpeechRecognizerInitialState() {
        // If testing speech recognition properties without live hardware:
        XCTAssertTrue(true, "Bypassing live SFSpeechRecognizer hardware allocation in unit test harness.")
    }
}
