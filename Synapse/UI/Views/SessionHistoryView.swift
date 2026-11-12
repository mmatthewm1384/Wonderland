import AVFoundation
import SwiftUI

public struct SessionSummary: Identifiable, Sendable {
    public var id: String {
        self.sessionId
    }

    public let sessionId: String
    public let transcript: String
    public let metadata: String
}

public struct SessionHistoryView: View {
    private let vaultManager = SecureVaultManager()
    @State private var sessions: [SessionSummary] = []
    @State private var searchText = ""
    @State private var selectedSessionMetadata: String?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var isLoading = true

    public init() {}

    public var body: some View {
        ZStack {
            AURA.darkBase
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("SECURE VAULT SESSIONS")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                    Button(
                        action: { self.loadSessions() },
                        label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(AURA.focalAccent)
                        }
                    )
                }
                .padding(.horizontal)
                .padding(.top, 16)

                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search transcripts or sessions...", text: self.$searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                    if !self.searchText.isEmpty {
                        Button(
                            action: { self.searchText = "" },
                            label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        )
                    }
                }
                .padding(12)
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal)

                if self.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AURA.focalAccent)
                    Spacer()
                } else if self.filteredSessions.isEmpty {
                    Spacer()
                    Text("No matching sessions found.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Spacer()
                } else {
                    List {
                        ForEach(self.filteredSessions) { session in
                            Button(
                                action: {
                                    self.stopAudio()
                                    Task {
                                        let loaded = try? await vaultManager.loadSession(
                                            sessionId: session.sessionId
                                        )
                                        if let loaded {
                                            self.selectedSessionMetadata = loaded.metadata
                                            self.setupAudioPlayer(with: loaded.audioData)
                                        }
                                    }
                                },
                                label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Image(systemName: "lock.shield.fill")
                                                .foregroundColor(AURA.focalAccent)
                                            Text(session.sessionId)
                                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Text(
                                            session.transcript.isEmpty
                                                ? "No transcript recorded."
                                                : session.transcript
                                        )
                                        .font(.system(size: 12, design: .default))
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                    }
                                    .padding(.vertical, 6)
                                }
                            )
                            .listRowBackground(Color.black.opacity(0.2))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }

                // Selected Session Inspector Sheet / Card
                if let metadata = selectedSessionMetadata {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("SESSION INSPECTOR")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(AURA.focalAccent)
                            Spacer()
                            Button("Close") {
                                self.stopAudio()
                                self.selectedSessionMetadata = nil
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                        }

                        // Audio Playback Controls
                        HStack(spacing: 16) {
                            Button(
                                action: {
                                    self.togglePlayback()
                                },
                                label: {
                                    Image(systemName: self.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(AURA.focalAccent)
                                }
                            )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(self.isPlaying ? "Playing recording..." : "Audio ready")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(.white)
                                if let player = audioPlayer {
                                    Text(String(format: "Duration: %.1fs", player.duration))
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)

                        ScrollView {
                            Text(metadata)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 120)
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            self.loadSessions()
        }
    }

    private var filteredSessions: [SessionSummary] {
        if self.searchText.isEmpty {
            self.sessions
        } else {
            self.sessions.filter {
                $0.sessionId.localizedCaseInsensitiveContains(self.searchText) ||
                    $0.transcript.localizedCaseInsensitiveContains(self.searchText)
            }
        }
    }

    private func loadSessions() {
        Task {
            self.isLoading = true
            do {
                let ids = try await vaultManager.listSessions()
                var loadedSummaries: [SessionSummary] = []
                for id in ids {
                    if let session = try? await vaultManager.loadSession(sessionId: id) {
                        let transcript = self.extractTranscript(from: session.metadata)
                        loadedSummaries.append(
                            SessionSummary(
                                sessionId: id,
                                transcript: transcript,
                                metadata: session.metadata
                            )
                        )
                    } else {
                        loadedSummaries.append(SessionSummary(sessionId: id, transcript: "", metadata: ""))
                    }
                }
                Task { @MainActor in
                    self.sessions = loadedSummaries.sorted(by: { $0.sessionId > $1.sessionId })
                    self.isLoading = false
                }
            } catch {
                Task { @MainActor in
                    self.isLoading = false
                }
            }
        }
    }

    private func extractTranscript(from metadata: String) -> String {
        if let range = metadata.range(of: "\"transcript\"\\s*:\\s*\"([^\"]*)\"", options: .regularExpression) {
            let match = metadata[range]
            let parts = match.split(separator: ":")
            if parts.count > 1 {
                return parts[1].trimmingCharacters(in: .init(charactersIn: " \""))
            }
        }
        return ""
    }

    private func setupAudioPlayer(with data: Data) {
        do {
            self.audioPlayer = try AVAudioPlayer(data: data)
            self.audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to initialize AVAudioPlayer: \(error)")
        }
    }

    private func togglePlayback() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            self.isPlaying = false
        } else {
            player.play()
            self.isPlaying = true
        }
    }

    private func stopAudio() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        self.isPlaying = false
    }
}
