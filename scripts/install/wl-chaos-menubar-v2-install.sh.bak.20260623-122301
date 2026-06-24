#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APP_ROOT="$ROOT/apps/macos/wl-chaos-menubar"
SRC="$APP_ROOT/Sources/wl-chaos-menubar"
BIN="$APP_ROOT/build/wl-chaos-menubar"
WRAP="$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-menubar"

mkdir -p "$SRC" "$APP_ROOT/build" "$(dirname "$WRAP")"

cat > "$SRC/main.swift" <<'SWIFT'
import AppKit
import Foundation

let wlRoot = NSHomeDirectory() + "/Wonderland"
let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
let chaosDir = wlRoot + "/vault/chaos"
let contractPath = chaosDir + "/visual-chaos-contract.json"
let aetherPath = chaosDir + "/chaos-aether.json"
let reportPath = wlRoot + "/vault/08-Operations/reports/chaos-governance-report.json"

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
    var lastActionAt = ""

    func applicationDidFinishLaunching(_ notification: Notification) {
        item.button?.title = "☄︎ WL"
        refresh()
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.refresh()
        }
    }

    func refresh() {
        item.button?.title = chaosActive() ? "☄︎ CHAOS" : "☄︎ WL"
        buildMenu()
    }

    func buildMenu() {
        menu.removeAllItems()

        menu.addItem(disabled(chaosActive() ? "☄︎ Mode: CHAOS ACTIVE" : "☄︎ Mode: normal"))
        menu.addItem(disabled(aetherActive() ? "Aether: active" : "Aether: inactive"))
        menu.addItem(disabled(watchdogRunning() ? "Watchdog: running" : "Watchdog: stopped"))

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
        menu.addItem(action("Start Watchdog", #selector(startWatchdog)))
        menu.addItem(action("Stop Watchdog", #selector(stopWatchdog)))

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

    @objc func startWatchdog() {
        let output = shell("\(chaosBin)/wl-chaos-watchdog up")
        mark(output.components(separatedBy: "\n").last ?? "Watchdog started")
    }

    @objc func stopWatchdog() {
        let output = shell("\(chaosBin)/wl-chaos-watchdog down")
        mark(output.components(separatedBy: "\n").last ?? "Watchdog stopped")
    }

    @objc func openChaosFolder() {
        shell("open '\(chaosDir)'")
    }

    @objc func openContract() {
        shell("open '\(contractPath)'")
    }

    @objc func openGovernance() {
        shell("open '\(reportPath)'")
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
SWIFT

cd "$APP_ROOT"
swift build -c release

cp "$APP_ROOT/.build/release/wl-chaos-menubar" "$BIN"

cat > "$WRAP" <<EOF
#!/usr/bin/env bash
exec "$BIN"
EOF

chmod +x "$BIN" "$WRAP"

pkill -f wl-chaos-menubar 2>/dev/null || true

echo "PASS rebuilt wl-chaos-menubar v2"
echo "Run:"
echo "  $WRAP &"
