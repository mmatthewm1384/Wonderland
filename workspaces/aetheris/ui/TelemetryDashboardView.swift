import SwiftUI

@available(macOS 14.0, *)
public struct TelemetryDashboardView: View {
    @StateObject private var telemetry = TelemetryManager()

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with Stress Test Action Button
            HStack {
                Circle()
                    .fill(self.telemetry.currentSnapshot.volatileStateActive ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                    .shadow(color: self.telemetry.currentSnapshot.volatileStateActive ? .green.opacity(0.8) : .red.opacity(0.8), radius: 4)

                Text("SYSTEM TELEMETRY & OBSERVABILITY")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                Button(action: {
                    self.telemetry.triggerStressTest()
                }) {
                    Text(self.telemetry.isUnderStressTest ? "STRESS TESTING..." : "RUN STRESS TEST")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(self.telemetry.isUnderStressTest ? Color.orange.opacity(0.3) : Color.cyan.opacity(0.2))
                        .foregroundColor(self.telemetry.isUnderStressTest ? .orange : .cyan)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .disabled(self.telemetry.isUnderStressTest)

                Text(self.telemetry.currentSnapshot.timestamp, style: .time)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Divider()
                .background(Color.white.opacity(0.1))

            // Metrics Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                TelemetryMetricCard(
                    title: "MICRO-VM CPU",
                    value: String(format: "%.1f%%", self.telemetry.currentSnapshot.cpuUsage),
                    tint: .cyan
                )

                TelemetryMetricCard(
                    title: "ALLOCATED RAM",
                    value: String(format: "%.1f MB", self.telemetry.currentSnapshot.memoryAllocatedMB),
                    tint: .purple
                )

                TelemetryMetricCard(
                    title: "VECTOR THROUGHPUT",
                    value: String(format: "%.0f QPS", self.telemetry.currentSnapshot.vectorThroughputQPS),
                    tint: .green
                )

                TelemetryMetricCard(
                    title: "QUERY LATENCY",
                    value: String(format: "%.2f ms", self.telemetry.currentSnapshot.queryLatencyMs),
                    tint: .orange
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.black.opacity(0.85))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(16)
    }
}

private struct TelemetryMetricCard: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(self.title)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(.gray)

            Text(self.value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: self.tint.opacity(0.4), radius: 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(self.tint.opacity(0.3), lineWidth: 1)
        )
    }
}
