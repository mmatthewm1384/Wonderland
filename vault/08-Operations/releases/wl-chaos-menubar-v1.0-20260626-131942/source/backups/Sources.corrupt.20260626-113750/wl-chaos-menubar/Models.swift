cat > Sources/wl-chaos-menubar/Models.swift <<'EOF'
import Foundation

struct ChaosStatus: Codable {
    let mode: String
    let aether: String
    let watchdog: String
    let countdown: String
    let last_checkin: String
    let last_activity: String
    let escalation_window: String
    let chaos_active: Bool
    let rings: Int
    let rotation: Double
    let intensity: Double
    let particles: Int
    let living_ratio: Double

    var countdownSummary: String {
        countdown
            .split(separator: "\n")
            .first(where: { $0.contains("Escalation in:") })
            .map { String($0).replacingOccurrences(of: "Escalation in: ", with: "") }
            ?? countdown
    }

    var lastResult: String {
        if aether == "active" && watchdog == "running" { return "OK" }
        return "DEGRADED"
    }

    static func fallback() -> ChaosStatus {
        ChaosStatus(
            mode: "normal",
            aether: "unknown",
            watchdog: "unknown",
            countdown: "Unavailable",
            last_checkin: "Unavailable",
            last_activity: "unknown",
            escalation_window: "unknown",
            chaos_active: false,
            rings: 0,
            rotation: 0.0,
            intensity: 0.0,
            particles: 0,
            living_ratio: 0.0
        )
    }

    static func load() -> ChaosStatus {
        let result = Shell.run(Paths.statusAdapter, [])
        guard result.exitCode == 0,
              let data = result.stdout.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(ChaosStatus.self, from: data)
        else {
            return fallback()
        }
        return decoded
    }
}
EOF
