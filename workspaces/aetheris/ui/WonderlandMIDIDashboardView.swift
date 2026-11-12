// /Users/wonderland/Developer/projects/aetheris/ui/WonderlandMIDIDashboardView.swift

import SwiftUI

public struct WonderlandMIDIDashboardView: View {
    @ObservedObject public var viewModel: WonderlandRuntimeViewModel

    public init(viewModel: WonderlandRuntimeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            self.headerSection

            Divider()
                .background(Color.white.opacity(0.1))

            self.connectionStatusIndicator
        }
        .padding(20)
        .background(Color(.sRGB, red: 0.06, green: 0.06, blue: 0.08, opacity: 1.0))
        .preferredColorScheme(.dark)
    }

    private var headerSection: some View {
        HStack {
            Text("MIDI SUBSYSTEM")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
            Spacer()
        }
    }

    private var connectionStatusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(self.viewModel.midiManager.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            Text(self.viewModel.midiManager.isConnected ? "CONNECTED" : "OFFLINE")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
        }
    }
}
