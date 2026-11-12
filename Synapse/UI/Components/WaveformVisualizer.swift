import SwiftUI

public struct WaveformVisualizer: View {
    public var samples: [Float]

    public init(samples: [Float] = []) {
        self.samples = samples.isEmpty ? Array(repeating: 0.1, count: 30) : samples
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(self.samples.enumerated()), id: \.offset) { index, amplitude in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index % 2 == 0 ? AURA.focalAccent : AURA.blue)
                    .frame(width: 4, height: max(10, CGFloat(amplitude) * 100))
                    .animation(.easeInOut(duration: 0.1), value: amplitude)
            }
        }
        .padding()
        .background(AURA.darkBase)
        .cornerRadius(12)
    }
}
