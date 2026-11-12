// ==============================================================================
// Wonderland: Project Aetheris // Dashboard Components
// File: ui/WonderlandDashboardComponents.swift
// ==============================================================================

import SwiftUI

// MARK: - Memory Crystal Item Model

public struct MemoryCrystalItem: Identifiable, Sendable {
    public let id = UUID()
    public let key: String
    public let sizeBytes: UInt64
    public let checksum: String
    public let timestamp: Date

    public init(key: String, sizeBytes: UInt64, checksum: String, timestamp: Date = Date()) {
        self.key = key
        self.sizeBytes = sizeBytes
        self.checksum = checksum
        self.timestamp = timestamp
    }
}

// MARK: - Memory Crystal Row View

public struct MemoryCrystalRowView: View {
    public let crystal: MemoryCrystalItem
    @ObservedObject public var viewModel: WonderlandRuntimeViewModel

    public init(crystal: MemoryCrystalItem, viewModel: WonderlandRuntimeViewModel) {
        self.crystal = crystal
        self.viewModel = viewModel
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "cube.transparent")
                .foregroundColor(.cyan)
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(self.crystal.key)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(.primary)

                Text("Checksum: \(self.crystal.checksum.prefix(12))...")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(self.crystal.sizeBytes / 1024) KB")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.cyan)

                Text(self.crystal.timestamp, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.black.opacity(0.2))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
        )
    }
}
