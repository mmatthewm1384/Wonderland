// /Users/wonderland/Developer/projects/aetheris/ui/WonderlandMIDIMappingModal.swift

import SwiftUI

public struct WonderlandMIDIMappingModal: View {
    @ObservedObject public var viewModel: WonderlandRuntimeViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var ccText: String = "16"
    @State private var selectedParameter: WonderlandRuntimeParameter = .throughput

    public init(viewModel: WonderlandRuntimeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            self.headerSection

            Divider()
                .background(Color.white.opacity(0.1))

            self.activeMappingsSection

            Divider()
                .background(Color.white.opacity(0.1))

            self.assignmentFormSection
        }
        .padding(20)
        .frame(width: 420, height: 420)
        .background(Color(.sRGB, red: 0.06, green: 0.06, blue: 0.08, opacity: 1.0))
        .preferredColorScheme(.dark)
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("MIDI CC MAPPING MATRIX")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                Text("Bind Akai hardware controls to runtime subsystems")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: { self.dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
        }
    }

    private var activeMappingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CURRENT HARDWARE BINDINGS")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(Array(self.viewModel.midiManager.knobMappings.keys.sorted()), id: \.self) { cc in
                        self.mappingRow(for: cc)
                    }
                }
            }
            .frame(height: 140)
        }
    }

    @ViewBuilder
    private func mappingRow(for cc: UInt8) -> some View {
        if let paramName = viewModel.midiManager.knobMappings[cc] {
            HStack {
                Text("CC \(cc)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .frame(width: 60, alignment: .leading)

                Image(systemName: "arrow.right")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)

                Text(paramName)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    self.viewModel.midiManager.knobMappings.removeValue(forKey: cc)
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 9))
                        .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
            .padding(10)
            .background(Color.black.opacity(0.4))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.cyan.opacity(0.2), lineWidth: 1))
        }
    }

    private var assignmentFormSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ASSIGN NEW CONTROL")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CC NUMBER")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.gray)
                    TextField("CC", text: self.$ccText)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11, design: .monospaced))
                        .frame(width: 70)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("TARGET SUBSYSTEM PARAMETER")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.gray)
                    Picker("", selection: self.$selectedParameter) {
                        ForEach(WonderlandRuntimeParameter.allCases) { param in
                            Text(param.rawValue).tag(param)
                        }
                    }
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                }
            }

            Button(action: {
                if let ccValue = UInt8(ccText) {
                    self.viewModel.midiManager.knobMappings[ccValue] = self.selectedParameter.rawValue
                }
            }) {
                Text("APPLY MAPPING")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.cyan.opacity(0.2))
                    .foregroundColor(.cyan)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.cyan.opacity(0.4), lineWidth: 1))
            }
            .padding(.top, 4)
        }
    }
}

public enum WonderlandRuntimeParameter: String, CaseIterable, Identifiable {
    case throughput = "Vector Throughput Scaling"
    case latency = "k-NN Latency Ceiling"
    case benchmark = "Benchmark Trigger Threshold"
    case memoryAudit = "Memory Crystal Audit Rate"

    public var id: String {
        rawValue
    }
}
