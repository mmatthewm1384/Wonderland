// ==============================================================================
// Wonderland: Project Aetheris // Memory Crystal Ledger View
// File: ui/MemoryCrystalLedger.swift
// ==============================================================================

import SwiftUI

public struct MemoryCrystalLedgerView: View {
    @ObservedObject public var viewModel: WonderlandRuntimeViewModel

    public init(viewModel: WonderlandRuntimeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            self.headerView
            self.ledgerListView
        }
        .padding(16)
        .background(Color.black.opacity(0.4))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
        )
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "cylinder.split.1x2")
                .foregroundColor(.cyan)
            Text("CRYSTAL LEDGER & PERSISTENT MEMORY")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
            Spacer()
        }
    }

    private var ledgerListView: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Example ledger entries aligned with Crystal architecture
                self.crystalRow(label: "core.kernel.state", size: "1.2 MB", status: "VERIFIED")
                self.crystalRow(label: "vector.index.partition_0", size: "45.8 MB", status: "INDEXED")
                self.crystalRow(label: "mesh.topology.nodes", size: "340 KB", status: "SYNCED")
            }
        }
    }

    private func crystalRow(label: String, size: String, status: String) -> some View {
        HStack {
            self.labelView(label: label, status: status)
            Spacer()
            self.sizeView(size: size)
        }
        .padding(10)
        .background(Color.white.opacity(0.03))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func labelView(label: String, status: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text("STATUS: \(status)")
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.cyan)
        }
    }

    private func sizeView(size: String) -> some View {
        Text(size)
            .font(.system(size: 11, design: .monospaced))
            .foregroundColor(.secondary)
    }
}
