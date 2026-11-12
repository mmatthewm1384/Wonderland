import AVFoundation
import Foundation
import SwiftUI

public struct PlaybackControlView: View {
    @ObservedObject public var controlState: PlaybackControlState
    @State private var selectedTab: ControlTab = .speed

    public enum ControlTab: String, CaseIterable {
        case speed = "Playback speed"
        case subtitles = "Subtitles delay"
        case audio = "Audio delay"
    }

    public init(controlState: PlaybackControlState) {
        self.controlState = controlState
    }

    public var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(self.selectedTab.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    self.controlState.resetAll()
                }, label: {
                    Text("Reset")
                })
                .foregroundColor(AURA.focalAccent)
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                ForEach(ControlTab.allCases, id: \.self) { tab in
                    Button(
                        action: { self.selectedTab = tab },
                        label: {
                            Text(tab.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    self.selectedTab == tab
                                        ? Color.gray.opacity(0.4)
                                        : Color.gray.opacity(0.15)
                                )
                                .cornerRadius(12)
                        }
                    )
                }
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                switch self.selectedTab {
                case .speed:
                    self.valueLabel(text: String(format: "%.2fx", self.controlState.playbackRate))
                    Slider(value: self.$controlState.playbackRate, in: 0.5 ... 2.0, step: 0.25)
                        .accentColor(AURA.focalAccent)
                case .subtitles:
                    self.valueLabel(text: self.formatMillis(self.controlState.subtitlesDelay))
                    Slider(value: self.$controlState.subtitlesDelay, in: -30.0 ... 30.0, step: 0.1)
                        .accentColor(AURA.focalAccent)
                case .audio:
                    self.valueLabel(text: self.formatMillis(self.controlState.audioDelay))
                    Slider(value: self.$controlState.audioDelay, in: -5.0 ... 5.0, step: 0.05)
                        .accentColor(AURA.focalAccent)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .padding(.vertical, 20)
        .background(AURA.darkBase)
        .cornerRadius(20)
    }

    private func valueLabel(text: String) -> some View {
        Text(text)
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundColor(AURA.focalAccent)
            .padding(.vertical, 8)
    }

    private func formatMillis(_ interval: TimeInterval) -> String {
        let milliseconds = interval * 1000
        return String(format: "%.1f ms", milliseconds)
    }
}
