import Foundation

struct ChaosSchedulerStatus {
    let line: String
    let detail: String
}

enum ChaosSchedulerStatusReader {
    static let root = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland")

    static func load() -> ChaosSchedulerStatus {
        let scheduleURL = root.appendingPathComponent("vault/chaos/escalation-schedule.json")

        guard
            let data = try? Data(contentsOf: scheduleURL),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return ChaosSchedulerStatus(
                line: "⚪ Schedule Not Configured",
                detail: "No escalation schedule"
            )
        }

        let enabled = json["enabled"] as? Bool ?? false
        let strategy = json["strategy"] as? String ?? "unknown"
        let hold = json["initial_hold_hours"] as? Double ?? 6.0

        guard enabled else {
            return ChaosSchedulerStatus(
                line: "⚪ Schedule Disabled",
                detail: "\(strategy), hold \(formatHours(hold))"
            )
        }

        let eval = evaluateCurrentTarget(schedule: json)

        return ChaosSchedulerStatus(
            line: "🟢 Schedule \(strategy)",
            detail: "Target \(eval.mode) · risk \(eval.risk)"
        )
    }

    private static func evaluateCurrentTarget(schedule: [String: Any]) -> (mode: String, risk: Int) {
        guard
            let startedRaw = schedule["started_at"] as? String,
            let started = ChaosTime.parse(startedRaw),
            let levels = schedule["levels"] as? [[String: Any]]
        else {
            return ("unknown", -1)
        }

        let hold = schedule["initial_hold_hours"] as? Double ?? 6.0
        let elapsed = Date().timeIntervalSince(started) / 3600.0
        let activeWindow = max(0.0, elapsed - hold)

        let sorted = levels.sorted {
            (($0["after_hours"] as? Double) ?? 0.0) < (($1["after_hours"] as? Double) ?? 0.0)
        }

        var selected = sorted.first

        for level in sorted {
            let after = level["after_hours"] as? Double ?? 0.0
            if activeWindow >= after {
                selected = level
            }
        }

        return (
            selected?["mode"] as? String ?? "unknown",
            selected?["risk"] as? Int ?? -1
        )
    }

    private static func formatHours(_ value: Double) -> String {
        if value == floor(value) {
            return "\(Int(value))h"
        }
        return String(format: "%.1fh", value)
    }
}
