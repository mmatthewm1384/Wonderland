import Foundation

enum ChaosAudit {
    static let root = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland")
    static let logURL = root.appendingPathComponent("vault/chaos/menubar-audit.jsonl")

    static func record(model: ChaosModel, authorization: ChaosAuthorization, humanApproved: Bool?) {
        let event: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "model": model.id,
            "title": model.title,
            "risk_level": model.riskLevel,
            "authorized": authorization.allowed,
            "reason": authorization.reason,
            "lease_id": authorization.leaseID ?? NSNull(),
            "fingerprint_short": authorization.fingerprintShort ?? NSNull(),
            "human_approved": humanApproved ?? NSNull()
        ]

        do {
            try FileManager.default.createDirectory(
                at: logURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            let data = try JSONSerialization.data(withJSONObject: event, options: [.sortedKeys])
            guard let line = String(data: data, encoding: .utf8) else { return }

            if FileManager.default.fileExists(atPath: logURL.path) {
                let handle = try FileHandle(forWritingTo: logURL)
                try handle.seekToEnd()
                try handle.write(contentsOf: Data((line + "\n").utf8))
                try handle.close()
            } else {
                try Data((line + "\n").utf8).write(to: logURL, options: .atomic)
            }
        } catch {
            NSLog("ChaosAudit failed: \(error.localizedDescription)")
        }
    }
    static func recordExecutionSource(model: ChaosModel, source: String, success: Bool) {
        let event: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "event": "execution_source",
            "model": model.id,
            "title": model.title,
            "risk_level": model.riskLevel,
            "source": source,
            "success": success
        ]

        do {
            try FileManager.default.createDirectory(
                at: logURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            let data = try JSONSerialization.data(withJSONObject: event, options: [.sortedKeys])
            guard let line = String(data: data, encoding: .utf8) else { return }

            if FileManager.default.fileExists(atPath: logURL.path) {
                let handle = try FileHandle(forWritingTo: logURL)
                try handle.seekToEnd()
                try handle.write(contentsOf: Data((line + "\n").utf8))
                try handle.close()
            } else {
                try Data((line + "\n").utf8).write(to: logURL, options: .atomic)
            }
        } catch {
            NSLog("ChaosAudit execution source failed: \(error.localizedDescription)")
        }
    }

}
