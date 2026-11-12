// ==============================================================================
// Wonderland: Project Aetheris // Dashboard View
// File: ui/WonderlandDashboardView.swift
// ==============================================================================

import SwiftUI

public struct WonderlandDashboardView: View {
    @ObservedObject public var viewModel: WonderlandRuntimeViewModel

    public init(viewModel: WonderlandRuntimeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            self.vmStatusHeader
            self.benchmarkActionRow
            Divider().background(Color.cyan.opacity(0.3))
            self.telemetryLogSection
        }
        .padding(16)
        .background(Color.black.opacity(0.5))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
        )
    }

    private var vmStatusHeader: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(self.viewModel.isVMActive ? Color.green : Color.red)
                .frame(width: 8, height: 8)
                .shadow(color: self.viewModel.isVMActive ? Color.green.opacity(0.6) : Color.red.opacity(0.6), radius: 4)

            Text(self.viewModel.isVMActive ? "VM ACTIVE" : "VM STANDBY")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(10)
        .background(Color.white.opacity(0.03))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(self.viewModel.isVMActive ? Color.green.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    private var benchmarkActionRow: some View {
        HStack {
            Text("AETHERIS TELEMETRY & CONTROL")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)

            Spacer()

            Button(action: { self.viewModel.runBenchmark() }) {
                Text("RUN BENCHMARK")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
    }

    private var telemetryLogSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LOGS")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(self.viewModel.telemetryLogs) { log in
                        self.logRow(log: log)
                    }
                }
            }
            .frame(maxHeight: 180)
        }
    }

    private func logRow(log: TelemetryLogEntry) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("[\(log.timestamp)]")
                .foregroundColor(.gray)
            Text("[\(log.source)]")
                .foregroundColor(.cyan)
            Text(log.message)
                .foregroundColor(.white)
        }
        .font(.system(size: 10, design: .monospaced))
    }
}
