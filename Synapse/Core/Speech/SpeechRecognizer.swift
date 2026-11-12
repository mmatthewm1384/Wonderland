import AVFoundation
import Foundation
#if !TESTING
    import Speech
#endif

extension AVAudioPCMBuffer: @retroactive @unchecked Sendable {}

@MainActor
public class SpeechRecognizer: ObservableObject {
    @Published public var transcribedText: String = ""
    @Published public var isRecognizing: Bool = false

    #if !TESTING
        private let speechRecognizer: SFSpeechRecognizer?
        private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        private var recognitionTask: SFSpeechRecognitionTask?
    #endif
    private let queue = DispatchQueue(label: "com.synapse.speechRecognizer")

    public init() {
        #if !TESTING
            self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
            self.requestAuthorization()
        #endif
    }

    public func requestAuthorization() {
        #if !TESTING
            SFSpeechRecognizer.requestAuthorization { authStatus in
                DispatchQueue.main.async {
                    switch authStatus {
                    case .authorized:
                        print("Speech recognition authorized.")
                    default:
                        print("Speech recognition not authorized.")
                    }
                }
            }
        #endif
    }

    public func startTranscribing() throws {
        #if !TESTING
            guard let speechRecognizer, speechRecognizer.isAvailable else {
                throw NSError(
                    domain: "SpeechRecognizer",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Speech recognizer is not available."]
                )
            }

            self.recognitionTask?.cancel()
            self.recognitionTask = nil

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true

            self.recognitionTask = speechRecognizer.recognitionTask(
                with: recognitionRequest
            ) { [weak self] result, error in
                if let result {
                    let text = result.bestTranscription.formattedString
                    Task { @MainActor [weak self] in
                        self?.transcribedText = text
                    }
                }

                if error != nil || (result?.isFinal ?? false) {
                    Task { @MainActor [weak self] in
                        self?.stopTranscribing()
                    }
                }
            }

            self.isRecognizing = true
        #endif
    }

    nonisolated public func appendBuffer(_ buffer: AVAudioPCMBuffer) {
        #if !TESTING
        self.queue.async { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                self.recognitionRequest?.append(buffer)
            }
        }
        #endif
    }

    public func stopTranscribing() {
        #if !TESTING
            self.recognitionRequest?.endAudio()
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
            self.recognitionRequest = nil
        #endif
        self.isRecognizing = false
    }
}
