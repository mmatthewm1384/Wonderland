import SwiftUI

public struct VolatileSparkPanelView: View {
    @ObservedObject public var viewModel: WonderlandRuntimeViewModel
    @State private var selectedPayloadSize: Int = 4096

    public init(viewModel: WonderlandRuntimeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("VOLATILE SPARK // EPHEMERAL COMPUTE")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(self.viewModel.isSparkActive ? Color.orange : Color.gray.opacity(0.4))
                        .frame(width: 6, height: 6)
                    Text(self.viewModel.isSparkActive ? "BUFFER ACTIVE (\(self.viewModel.activeSparkBytes)B)" : "IDLE / ZEROIZED")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(self.viewModel.isSparkActive ? .orange : .gray)
                }
            }

            HStack(spacing: 12) {
                Picker("Payload Size", selection: self.$selectedPayloadSize) {
                    Text("1 KB").tag(1024)
                    Text("4 KB").tag(4096)
                    Text("64 KB").tag(65536)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 220)

                Button(action: {
                    self.viewModel.executeVolatileSparkPass(payloadSize: self.selectedPayloadSize)
                }) {
                    Text("SPARK COMPUTE PASS")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                        )
                }
                .disabled(self.viewModel.isSparkActive)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
}
