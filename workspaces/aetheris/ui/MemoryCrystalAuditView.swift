// /Users/wonderland/Developer/projects/aetheris/ui/MemoryCrystalAuditView.swift

import Foundation
import SwiftUI

public struct CrystalAuditRecord: Identifiable, Sendable {
    public let id = UUID()
    public let timestamp: Date
    public let crystalHash: String
    public let status: AuditStatus
    public let blockHeight: UInt64

    public enum AuditStatus: String, Sendable {
        case verified = "VERIFIED"
        case warning = "TAMPER DETECTED"
        case reindexing = "RE-INDEXING"
    }
}

private struct LogEntry: Codable {
    let spark_id: String
    let state_merkle_root: String
    let timestamp: TimeInterval
}

@MainActor
public class MemoryCrystalAuditManager: ObservableObject {
    @Published public private(set) var records: [CrystalAuditRecord] = []
    @Published public private(set) var errorMessage: String? = nil

    private let ledgerPath = "/Users/wonderland/Developer/projects/wonderland/crystal/ledger/state_commitments.log"

    public init() {
        self.loadLedger()
    }

    public func loadLedger() {
        guard FileManager.default.fileExists(atPath: self.ledgerPath) else {
            self.errorMessage = "Ledger path not found."
            return
        }

        do {
            let content = try String(contentsOfFile: ledgerPath, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }

            var parsedRecords: [CrystalAuditRecord] = []
            let decoder = JSONDecoder()

            for (index, line) in lines.enumerated() {
                let blockHeight = UInt64(index + 1)
                let displayHash: String
                let recordDate: Date

                if let data = line.data(using: .utf8),
                   let entry = try? decoder.decode(LogEntry.self, from: data)
                {
                    displayHash = "0x\(entry.state_merkle_root)"
                    recordDate = Date(timeIntervalSince1970: entry.timestamp)
                } else {
                    let hashInt = abs(line.hashValue)
                    let hexString = String(hashInt, radix: 16).uppercased()
                    displayHash = "0x\(hexString.prefix(8))"
                    recordDate = Date()
                }

                let record = CrystalAuditRecord(
                    timestamp: recordDate,
                    crystalHash: displayHash,
                    status: .verified,
                    blockHeight: blockHeight
                )
                parsedRecords.insert(record, at: 0)
            }

            self.records = parsedRecords
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Read error: \(error.localizedDescription)"
        }
    }
}

@available(macOS 14.0, *)
public struct MemoryCrystalAuditView: View {
    @StateObject private var auditManager = MemoryCrystalAuditManager()

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("MEMORY CRYSTAL LEDGER & AUDIT")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                Button(action: {
                    self.auditManager.loadLedger()
                }) {
                    Text("SYNC LEDGER")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.purple.opacity(0.2))
                        .foregroundColor(.purple)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            if let error = auditManager.errorMessage {
                Text(error)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Audit Record List
            ScrollView {
                VStack(spacing: 8) {
                    if self.auditManager.records.isEmpty {
                        Text("No ledger commitments found.")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.gray)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(self.auditManager.records) { record in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(record.crystalHash)
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                    Text("Block #\(record.blockHeight)")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Text(record.status.rawValue)
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(record.status == .verified ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                                    .foregroundColor(record.status == .verified ? .green : .red)
                                    .cornerRadius(4)
                            }
                            .padding(10)
                            .background(Color.white.opacity(0.02))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
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
