import AppKit
import Foundation

// WL_PALETTE_MENU_INDICATOR
let wlBackground = NSColor(calibratedRed: 0x05/255, green: 0x07/255, blue: 0x0A/255, alpha: 1.0)
let wlCyan = NSColor(calibratedRed: 0x00/255, green: 0xE5/255, blue: 0xFF/255, alpha: 1.0)
let wlPurple = NSColor(calibratedRed: 0x70/255, green: 0x00/255, blue: 0xFF/255, alpha: 1.0)
let wlGreen = NSColor(calibratedRed: 0x00/255, green: 0xFF/255, blue: 0x66/255, alpha: 1.0)

func wlStatusTitle(_ text: String, color: NSColor) -> NSAttributedString {
    return NSAttributedString(
        string: text,
        attributes: [
            .foregroundColor: color,
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
        ]
    )
}

let wlRoot = NSHomeDirectory() + "/Wonderland"
let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
let chaosDir = wlRoot + "/vault/chaos"
let contractPath = chaosDir + "/visual-chaos-contract.json"
let aetherPath = chaosDir + "/chaos-aether.json"
let reportPath = wlRoot + "/vault/08-Operations/reports/chaos-governance-report.json"
let runsLogPath = wlRoot + "/vault/ephemeral-runs.log"

func shell(_ command: String) -> String {
    let p = Process()
    let out = Pipe()
    let err = Pipe()

    p.executableURL = URL(fileURLWithPath: "/bin/bash")
    p.arguments = ["-lc", command]
    p.standardOutput = out
    p.standardError = err

    do {
        try p.run()
        p.waitUntilExit()
    } catch {
        return "ERROR: \(error.localizedDescription)"
    }

    let o = String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    let e = String(data: err.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    let text = (o + e).trimmingCharacters(in: .whitespacesAndNewlines)

    return text.isEmpty ? "OK" : text
}

func readFile(_ path: String) -> String {
    (try? String(contentsOfFile: path)) ?? ""
}

func chaosActive() -> Bool {
    readFile(contractPath).contains("\"chaos_active\": true")
}

func aetherActive() -> Bool {
    readFile(aetherPath).contains("permanent_high_chaos")
}

func watchdogRunning() -> Bool {
    let pidPath = chaosDir + "/chaos-watchdog.pid"
    let pid = readFile(pidPath).trimmingCharacters(in: .whitespacesAndNewlines)
    if pid.isEmpty { return false }
    let result = shell("ps -p \(pid) >/dev/null && echo yes || echo no")
    return result.contains("yes")
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu = NSMenu()

    var lastMessage = "Ready"
    var lastCountdown = ""
    var countdownDisplay = "Unknown"
    var countdownHours: Double? = nil
    var lastActionAt = ""
    var recentActivity: [String] = []
    var lastActivityDisplay = "Unknown"
    var lastCheckInDisplay = "Unknown"
    var contractPreview: [String] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        item.button?.attributedTitle = wlStatusTitle("◉ WL", color: wlCyan)
        updateCountdown()
        refresh()
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.updateCountdown()
            self.refresh()
        }
    }

    // WL_LIVE_COUNTDOWN_MENU
    // WL_COUNTDOWN_COLOR_STATE
    func formatCountdown(_ raw: String) -> String {
        let cleaned = raw
            .replacingOccurrences(of: "h", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let hoursValue = Double(cleaned) else {
            countdownHours = nil
            return raw
        }

        countdownHours = hoursValue

        let totalMinutes = max(0, Int(hoursValue * 60))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        return "\(hours)h \(String(format: "%02d", minutes))m"
    }

    func countdownColor() -> NSColor {
        guard let h = countdownHours else { return wlCyan }

        if h <= 0.25 {
            return wlGreen
        }

        if h <= 2.0 {
            return wlPurple
        }

        return wlCyan
    }

    func coloredDisabled(_ title: String, color: NSColor) -> NSMenuItem {
        let m = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        m.attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .foregroundColor: color,
                .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
            ]
        )
        m.isEnabled = false
        return m
    }

    func updateCountdown() {
        let output = shell("\(chaosBin)/wl-chaos-watchdog countdown")

        if let line = output
            .components(separatedBy: "\n")
            .first(where: { $0.contains("Escalation in:") }) {

            let raw = line
                .replacingOccurrences(of: "Escalation in:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            countdownDisplay = formatCountdown(raw)
        } else {
            countdownDisplay = "Unavailable"
        }
    }

    // WL_RECENT_ACTIVITY_MENU
    // WL_ACTIVITY_CONTRACT_PREVIEW
    func relativeAge(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date = formatter.date(from: iso)

        if date == nil {
            let fallback = ISO8601DateFormatter()
            fallback.formatOptions = [.withInternetDateTime]
            date = fallback.date(from: iso)
        }

        guard let d = date else {
            return "unknown"
        }

        let seconds = max(0, Int(Date().timeIntervalSince(d)))

        if seconds < 60 {
            return "\(seconds)s ago"
        }

        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)m ago"
        }

        let hours = minutes / 60
        let rem = minutes % 60
        return "\(hours)h \(rem)m ago"
    }

    func updateActivityAges() {
        let raw = readFile(runsLogPath)
        let lines = raw.split(separator: "\n").reversed()

        var lastAny: String? = nil
        var lastCheck: String? = nil

        for line in lines {
            guard
                let data = String(line).data(using: .utf8),
                let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                continue
            }

            let ts = (obj["recorded_at"] as? String)
                ?? (obj["valid_at"] as? String)
                ?? (obj["timestamp"] as? String)

            let event = obj["event"] as? String

            if lastAny == nil, let ts {
                lastAny = ts
            }

            if lastCheck == nil, event == "operator_checkin", let ts {
                lastCheck = ts
            }

            if lastAny != nil && lastCheck != nil {
                break
            }
        }

        lastActivityDisplay = lastAny.map(relativeAge) ?? "Unknown"
        lastCheckInDisplay = lastCheck.map(relativeAge) ?? "Unknown"
    }

    func updateContractPreview() {
        let raw = readFile(contractPath)

        guard
            let data = raw.data(using: .utf8),
            let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            contractPreview = ["Contract unavailable"]
            return
        }

        let active = (obj["chaos_active"] as? Bool) ?? false
        var lines: [String] = []

        lines.append("chaos_active: \(active ? "true" : "false")")

        if
            let apps = obj["apps"] as? [String: Any],
            let spin = apps["wl-spin-city"] as? [String: Any],
            let agitate = apps["wl-agitate"] as? [String: Any],
            let matrix = apps["wl-matrix"] as? [String: Any]
        {
            let rings = spin["rings"] ?? "?"
            let rotation = spin["rotation_speed"] ?? "?"
            let intensity = agitate["intensity"] ?? "?"
            let particles = matrix["particles"] ?? "?"
            let living = matrix["living_ratio"] ?? "?"

            lines.append("rings: \(rings)")
            lines.append("rotation: \(rotation)")
            lines.append("intensity: \(intensity)")
            lines.append("particles: \(particles)")
            lines.append("living_ratio: \(living)")
        }

        contractPreview = lines
    }

    func updateRecentActivity() {
        let raw = readFile(runsLogPath)
        let lines = raw
            .split(separator: "\n")
            .suffix(5)

        recentActivity = lines.compactMap { line in
            guard
                let data = String(line).data(using: .utf8),
                let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let event = obj["event"] as? String
            else {
                return nil
            }

            return event
        }.reversed()
    }

    func refresh() {
        item.button?.attributedTitle = chaosActive() ? wlStatusTitle("◉ CHAOS", color: wlPurple) : wlStatusTitle("◉ WL", color: wlCyan)
        updateActivityAges()
        updateContractPreview()
        updateRecentActivity()
        buildMenu()
    }

    func buildMenu() {
        menu.removeAllItems()

        menu.addItem(disabled(chaosActive() ? "☄︎ Mode: CHAOS ACTIVE" : "☄︎ Mode: normal"))
        menu.addItem(disabled(aetherActive() ? "Aether: active" : "Aether: inactive"))
        menu.addItem(disabled(watchdogRunning() ? "Watchdog: running" : "Watchdog: stopped"))

        menu.addItem(.separator())
        menu.addItem(disabled("Escalation In"))
        menu.addItem(coloredDisabled(countdownDisplay, color: countdownColor()))

        menu.addItem(.separator())
        menu.addItem(disabled("Last Activity"))
        menu.addItem(disabled(lastActivityDisplay))
        menu.addItem(disabled("Last Check-In"))
        menu.addItem(disabled(lastCheckInDisplay))

        menu.addItem(.separator())
        menu.addItem(disabled("Contract"))
        for line in contractPreview.prefix(6) {
            menu.addItem(disabled(line))
        }

        if !lastCountdown.isEmpty {
            menu.addItem(.separator())
            for line in lastCountdown.split(separator: "\n").prefix(5) {
                menu.addItem(disabled(String(line)))
            }
        }

        menu.addItem(.separator())
        menu.addItem(action("Check In", #selector(checkIn)))
        menu.addItem(action("Countdown", #selector(countdown)))
        menu.addItem(action("Reset Chaos", #selector(resetChaos)))
        menu.addItem(action("Panic", #selector(panic)))

        menu.addItem(.separator())
        menu.addItem(action("Governance Check", #selector(governance)))
        menu.addItem(action("Recovery Drill", #selector(recoveryDrill)))
        menu.addItem(action("Start Watchdog", #selector(startWatchdog)))
        menu.addItem(action("Stop Watchdog", #selector(stopWatchdog)))

        menu.addItem(.separator())
        menu.addItem(disabled("Recent Activity"))

        if recentActivity.isEmpty {
            menu.addItem(disabled("No recent events"))
        } else {
            for event in recentActivity.prefix(5) {
                menu.addItem(disabled("• \(event)"))
            }
        }

        menu.addItem(.separator())
        menu.addItem(disabled("Last: \(lastMessage)"))
        if !lastActionAt.isEmpty {
            menu.addItem(disabled("At: \(lastActionAt)"))
        }

        menu.addItem(.separator())
        menu.addItem(action("Open Chaos Folder", #selector(openChaosFolder)))
        menu.addItem(action("Open Contract", #selector(openContract)))
        menu.addItem(action("Open Governance Report", #selector(openGovernance)))
        menu.addItem(action("Quit", #selector(quit)))

        item.menu = menu
    }

    func disabled(_ title: String) -> NSMenuItem {
        let m = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        m.isEnabled = false
        return m
    }

    func action(_ title: String, _ selector: Selector) -> NSMenuItem {
        let m = NSMenuItem(title: title, action: selector, keyEquivalent: "")
        m.target = self
        return m
    }

    func mark(_ msg: String) {
        lastMessage = msg
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .medium
        lastActionAt = f.string(from: Date())
        refresh()
    }

    @objc func checkIn() {
        let output = shell("\(chaosBin)/wl-chaos-watchdog checkin")
        updateCountdown()
        mark(output.components(separatedBy: "\n").last ?? "Check-in complete")
    }

    @objc func countdown() {
        let output = shell("\(chaosBin)/wl-chaos-watchdog countdown")
        lastCountdown = output
        mark("Countdown updated")
    }

    @objc func resetChaos() {
        _ = shell("\(chaosBin)/wl-chaos-watchdog reset")
        _ = shell("\(chaosBin)/wl-visual-chaos write-contract")
        lastCountdown = ""
        mark("Chaos reset; contract normal")
    }

    @objc func panic() {
        let alert = NSAlert()
        alert.messageText = "Wonderland Panic"
        alert.informativeText = "This stops watchdog and wipes chaos/aether state."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Panic")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            let output = shell("\(chaosBin)/wl-chaos-panic --force 'Menubar Panic'")
            lastCountdown = ""
            mark(output.components(separatedBy: "\n").last ?? "Panic complete")
        }
    }

    @objc func governance() {
        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
        lastCountdown = output
        mark(output.contains("RESULT PASS") ? "Governance PASS" : "Governance FAIL")
    }

    // WL_DRILL_MENU_ACTION
    @objc func recoveryDrill() {
        let output = shell("\(wlRoot)/bin/wl-chaos-drill")
        lastCountdown = output
        updateCountdown()
        updateContractPreview()
        updateActivityAges()
        updateRecentActivity()
        mark(output.contains("RESULT PASS") ? "Recovery Drill PASS" : "Recovery Drill FAIL")
    }

    @objc func startWatchdog() {
        let output = shell("\(chaosBin)/wl-chaos-watchdog up")
        mark(output.components(separatedBy: "\n").last ?? "Watchdog started")
    }

    @objc func stopWatchdog() {
        let output = shell("\(chaosBin)/wl-chaos-watchdog down")
        mark(output.components(separatedBy: "\n").last ?? "Watchdog stopped")
    }

    @objc func openChaosFolder() {
        _ = shell("open '\(chaosDir)'")
    }

    @objc func openContract() {
        _ = shell("open '\(contractPath)'")
    }

    @objc func openGovernance() {
        _ = shell("open '\(reportPath)'")
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
