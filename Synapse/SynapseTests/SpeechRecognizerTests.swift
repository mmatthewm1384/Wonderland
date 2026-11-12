import XCTest

@MainActor
final class SpeechRecognizerTests: XCTestCase {
    func testSpeechRecognizerInitialState() {
        let recognizer = SpeechRecognizer()

        XCTAssertEqual(recognizer.transcribedText, "", "Transcribed text should be empty initially.")
        XCTAssertFalse(recognizer.isRecognizing, "Recognizer should not be active initially.")
    }

    func testStopTranscribingResetsState() {
        let recognizer = SpeechRecognizer()
        recognizer.isRecognizing = true

        recognizer.stopTranscribing()

        XCTAssertFalse(recognizer.isRecognizing, "Stopping transcription should set isRecognizing to false.")
    }
}
