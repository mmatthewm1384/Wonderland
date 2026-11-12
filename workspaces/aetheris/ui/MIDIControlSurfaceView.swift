// /Users/wonderland/Developer/projects/aetheris/ui/MIDIControlSurfaceView.swift

import SwiftUI

public struct MIDIControlSurfaceView: View {
    @ObservedObject public var midiManager: WonderlandMIDIManager

    public init(midiManager: WonderlandMIDIManager) {
        self.midiManager = midiManager
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            self.deviceStatusCard
            self.controlMetricsGrid
            self.padMatrixSection
        }
    }

    private var deviceStatusCard: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(self.midiManager.isConnected ? Color.green : Color.orange)
                .frame(width: 10, height: 10)
                .shadow(color: self.midiManager.isConnected ? Color.green.opacity(0.6) : Color.clear, radius: 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(self.midiManager.deviceName)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text(self.midiManager.isConnected ? "CONNECTED & LISTENING" : "WAITING FOR HARDWARE...")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(self.midiManager.isConnected ? .green : .gray)
            }

            Spacer()

            Button(action: { self.midiManager.toggleConnection() }) {
                Text(self.midiManager.isConnected ? "Disconnect" : "Scan Devices")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(self.midiManager.isConnected ? Color.red.opacity(0.2) : Color.cyan.opacity(0.2))
                    .foregroundColor(self.midiManager.isConnected ? .red : .cyan)
                    .cornerRadius(6)
            }
        }
        .padding(16)
        .background(Color(white: 0.08))
        .cornerRadius(10)
    }

    private var controlMetricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            self.ccStateBox
            self.noteStateBox
        }
    }

    private var ccStateBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CONTROL CHANGE (CC)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            if let cc = midiManager.lastReceivedCC {
                HStack(alignment: .firstTextBaseline) {
                    Text("CC \(cc.0)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                    Spacer()
                    Text("Val: \(cc.1)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.white)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.white.opacity(0.05))
                        Rectangle().fill(Color.cyan)
                            .frame(width: geometry.size.width * CGFloat(cc.1) / 127.0)
                    }
                }
                .frame(height: 4)
                .cornerRadius(2)
            } else {
                Text("No CC signals received")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.vertical, 8)
            }
        }
        .padding(14)
        .background(Color(white: 0.08))
        .cornerRadius(8)
    }

    private var noteStateBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOTE TRIGGER")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            if let note = midiManager.lastReceivedNote {
                HStack(alignment: .firstTextBaseline) {
                    Text("Note \(note.0)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.purple)
                    Spacer()
                    Text("Vel: \(note.1)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.white)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.white.opacity(0.05))
                        Rectangle().fill(Color.purple)
                            .frame(width: geometry.size.width * CGFloat(note.1) / 127.0)
                    }
                }
                .frame(height: 4)
                .cornerRadius(2)
            } else {
                Text("No active note triggers")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.vertical, 8)
            }
        }
        .padding(14)
        .background(Color(white: 0.08))
        .cornerRadius(8)
    }

    private var padMatrixSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PERFORMANCE PADS")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                ForEach(Array(0 ..< 8), id: \.self) { index in
                    self.padButton(for: index)
                }
            }
        }
        .padding(16)
        .background(Color(white: 0.08))
        .cornerRadius(10)
    }

    private func padButton(for index: Int) -> some View {
        let isTriggered = self.midiManager.lastReceivedNote?.0 == UInt8(36 + index)

        return Button(action: {
            self.midiManager.simulateNoteTrigger(note: UInt8(36 + index), velocity: 100)
        }) {
            VStack(spacing: 4) {
                Text("PAD 0\(index + 1)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                Text("C\(index + 1)")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(isTriggered ? Color.purple.opacity(0.4) : Color(white: 0.06))
            .foregroundColor(isTriggered ? .purple : .white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isTriggered ? Color.purple : Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
