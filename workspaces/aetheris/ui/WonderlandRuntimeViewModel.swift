// ==============================================================================
// Wonderland: Project Aetheris // Runtime View Model
// File: ui/WonderlandRuntimeViewModel.swift
// ==============================================================================

import Combine
import Foundation

public struct TelemetryLogEntry: Identifiable {
    public let id = UUID()
    public let timestamp: String
    public let source: String
    public let message: String
}

@MainActor
public class WonderlandRuntimeViewModel: ObservableObject {
    @Published public var ipcClient: AetherisIPCClient
    @Published public var telemetryManager: TelemetryManager
    @Published public var midiManager: WonderlandMIDIManager
    @Published public var isQueryExecuting: Bool = false
    @Published public var isSparkActive: Bool = true
    @Published public var activeSparkBytes: Int = 512
    @Published public var isVMActive: Bool = true
    @Published public var telemetryLogs: [TelemetryLogEntry] = [
        TelemetryLogEntry(timestamp: "19:13:00", source: "KERNEL", message: "Micro-VM initialized successfully."),
        TelemetryLogEntry(timestamp: "19:13:02", source: "CRYSTAL", message: "Memory ledger synchronized with APFS container.")
    ]

    private var cancellables = Set<AnyCancellable>()

    public init() {
        let client = AetherisIPCClient()
        let manager = TelemetryManager()
        let midi = WonderlandMIDIManager()

        manager.bindIPCClient(client)

        self.ipcClient = client
        self.telemetryManager = manager
        self.midiManager = midi
    }

    public func runBenchmark() {
        self.dispatchBenchmarkCommand()
    }

    public func dispatchBenchmarkCommand() {
        self.isQueryExecuting = true
        self.telemetryManager.triggerStressTest()
        self.telemetryManager.sendCommand(
            action: "run_benchmark",
            target: "vector_simd_partition",
            via: self.ipcClient
        )

        self.telemetryLogs.append(
            TelemetryLogEntry(
                timestamp: ISO8601DateFormatter().string(from: Date()),
                source: "BENCHMARK",
                message: "Executed SIMD vector distance partition benchmark."
            )
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.isQueryExecuting = false
        }
    }

    public func dispatchCheckpointCommand() {
        self.telemetryManager.sendCommand(
            action: "checkpoint_state",
            target: "crystal_memory",
            via: self.ipcClient
        )

        self.telemetryLogs.append(
            TelemetryLogEntry(
                timestamp: ISO8601DateFormatter().string(from: Date()),
                source: "CRYSTAL",
                message: "Checkpoint state saved to persistent memory."
            )
        )
    }

    public func executeVolatileSparkPass(payloadSize: Int) {
        self.isSparkActive = true
        self.activeSparkBytes = payloadSize
        self.telemetryManager.sendCommand(
            action: "execute_spark_pass",
            target: "volatile_buffer",
            via: self.ipcClient
        )

        self.telemetryLogs.append(
            TelemetryLogEntry(
                timestamp: ISO8601DateFormatter().string(from: Date()),
                source: "SPARK",
                message: "Executed volatile compute pass with payload size \(payloadSize) bytes."
            )
        )
    }
}
