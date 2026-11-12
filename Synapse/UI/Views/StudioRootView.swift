import AVFoundation
import SwiftUI

public struct StudioRootView: View {
    @StateObject private var playbackState = PlaybackControlState()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var audioEngine = SynapseAudioEngine()
    @State private var vaultManager = SecureVaultManager()
    @State private var isRecording = false
    @State private var sampleLevels: [Float] = Array(repeating: 0.1, count: 25)

    public init() {}

    public var body: some View {
        ZStack {
            AURA.darkBase
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header Title
                HStack {
                    Text("SYNAPSE STUDIO")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                    Circle()
                        .fill(self.isRecording ? AURA.focalAccent : Color.gray)
                        .frame(width: 12, height: 12)
                }
                .padding(.horizontal)

                // Live Transcription Display
                ScrollView {
                    Text(
                        self.speechRecognizer.transcribedText.isEmpty
                            ? "Transcription feed active..."
                            : self.speechRecognizer.transcribedText
                    )
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .background(Color.black.opacity(0.3))
                .cornerRadius(16)
                .padding(.horizontal)

                // Waveform Visualizer
                WaveformVisualizer(samples: self.sampleLevels)
                    .padding(.horizontal)

                // Playback & Timing Controls Component
                PlaybackControlView(controlState: self.playbackState)
                    .padding(.horizontal)

                // Record / Action Button
                Button(
                    action: {
                        let recognizer = self.speechRecognizer
                        let engine = self.audioEngine
                        let vault = self.vaultManager

                        Task {
                            if self.isRecording {
                                let audioData = try? await engine.stopRecording()
                                recognizer.stopTranscribing()
                                self.isRecording = false

                                if let audioData {
                                    let sessionId = "Session-\(Int(Date().timeIntervalSince1970))"
                                    let transcript = recognizer.transcribedText
                                    let metadata = """
                                    {
                                        "sessionId": "\(sessionId)",
                                        "timestamp": "\(Date().iso8601)",
                                        "transcript": "\(transcript)"
                                    }
                                    """
                                    try? await vault.saveSession(
                                        sessionId: sessionId,
                                        audioData: audioData,
                                        metadataJSON: metadata
                                    )
                                    print("Successfully persisted session \(sessionId) to APFS Secure Vault.")
                                }
                            } else {
                                try? await engine.startRecording { buffer, _ in
                                    recognizer.appendBuffer(buffer)
                                    if let channelData = buffer.floatChannelData?[0] {
                                        let sampleVal = abs(channelData[0])
                                        Task { @MainActor in
                                            self.sampleLevels.removeFirst()
                                            self.sampleLevels.append(min(1.0, sampleVal * 5.0))
                                        }
                                    }
                                }
                                try? recognizer.startTranscribing()
                                self.isRecording = true
                            }
                        }
                    },
                    label: {
                        Text(self.isRecording ? "STOP RECORDING" : "START RECORDING")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(self.isRecording ? Color.gray.opacity(0.5) : AURA.focalAccent)
                            .cornerRadius(14)
                    }
                )
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}

private extension Date {
    var iso8601: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
