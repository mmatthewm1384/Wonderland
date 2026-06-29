import Foundation

enum ChaosCountdownStatus {
    static let root = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland")

    static func leaseLine() -> String {
        let url = root.appendingPathComponent("vault/05-Registry/chaos/lease.json")

        guard
            let data = try? Data(contentsOf: url),
            let lease = try? JSONDecoder().decode(ChaosLease.self, from: data),
            let expires = ChaosTime.parse(lease.expires_at)
        else {
            return "🔴 Lease Missing"
        }

        let remaining = Int(expires.timeIntervalSince(Date()))
        if remaining <= 0 {
            return "🔴 Lease Expired"
        }

        return "🟢 Lease \(lease.mode) · \(formatSeconds(remaining))"
    }

    static func scheduleLine() -> String {
        let url = root.appendingPathComponent("vault/chaos/escalation-schedule.json")

        guard
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return "⚪ Schedule Not Configured"
        }

        guard (json["enabled"] as? Bool) == true else {
            return "⚪ Schedule Paused"
        }

        guard
            let startedRaw = json["started_at"] as? String,
            let started = ChaosTime.parse(startedRaw),
            let levels = json["levels"] as? [[String: Any]]
        else {
            return "🔴 Schedule Invalid"
        }

        let hold = json["initial_hold_hours"] as? Double ?? 6.0
        let elapsed = Date().timeIntervalSince(started) / 3600.0
        let activeWindow = max(0.0, elapsed - hold)

        let sorted = levels.sorted {
            (($0["after_hours"] as? Double) ?? 0) < (($1["after_hours"] as? Double) ?? 0)
        }

        if elapsed < hold {
            let remaining = Int((hold - elapsed) * 3600)
            return "🟢 Next: nudge in \(formatSeconds(remaining))"
        }

        for level in sorted {
            let after = level["after_hours"] as? Double ?? 0
            if after > activeWindow {
                let remaining = Int((after - activeWindow) * 3600)
                let mode = level["mode"] as? String ?? "unknown"
                return "🟢 Next: \(mode) in \(formatSeconds(remaining))"
            }
        }

        return "🔴 Schedule at max level"
    }

    static func formatSeconds(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60

        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(s)s" }
        return "\(s)s"
    }
}
