#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APP_ROOT="$ROOT/apps/macos/wl-chaos-menubar"
SRC="$APP_ROOT/Sources/wl-chaos-menubar"
BIN="$APP_ROOT/build/wl-chaos-menubar"

mkdir -p "$SRC" "$APP_ROOT/build"

cat > "$APP_ROOT/Package.swift" <<'SWIFT'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "wl-chaos-menubar",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "wl-chaos-menubar",
            path: "Sources/wl-chaos-menubar"
        )
    ]
)
SWIFT

cat > "$SRC/main.swift" <<'SWIFT'
import AppKit
import Foundation

let root = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Wonderland")

func run(_ args: [String]) {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/bin/bash")
    p.arguments = ["-lc", args.joined(separator: " ")]
    try? p.run()
}

func read(_ path: String) -> String {
    (try? String(contentsOfFile: path)) ?? ""
}

func chaosActive() -> Bool {
    let path = "\(NSHomeDirectory())/Wonderland/vault/chaos/visual-chaos-contract.json"
    return read(path).contains("\"chaos_active\": true")
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu = NSMenu()

    func applicationDidFinishLaunching(_ notification: Notification) {
        item.button?.title = chaosActive() ? "⚡ CHAOS" : "WL"
        buildMenu()
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.refresh()
        }
    }

    func refresh() {
        item.button?.title = chaosActive() ? "⚡ CHAOS" : "WL"
        buildMenu()
    }

    func buildMenu() {
        menu.removeAllItems()

        menu.addItem(NSMenuItem(
            title: chaosActive() ? "Mode: CHAOS ACTIVE" : "Mode: normal",
            action: nil,
            keyEquivalent: ""
        ))

        menu.addItem(.separator())

        menu.addItem(item("Check In", #selector(checkIn)))
        menu.addItem(item("Countdown", #selector(countdown)))
        menu.addItem(item("Reset Chaos", #selector(resetChaos)))
        menu.addItem(item("Panic", #selector(panic)))

        menu.addItem(.separator())

        menu.addItem(item("Open Chaos Folder", #selector(openChaosFolder)))
        menu.addItem(item("Open Contract", #selector(openContract)))
        menu.addItem(item("Open Governance Report", #selector(openGovernance)))

        menu.addItem(.separator())

        menu.addItem(item("Quit", #selector(quit)))

        item.menu = menu
    }

    func item(_ title: String, _ action: Selector) -> NSMenuItem {
        let m = NSMenuItem(title: title, action: action, keyEquivalent: "")
        m.target = self
        return m
    }

    @objc func checkIn() {
        run(["$HOME/Wonderland/bin/wl chaos checkin"])
        refresh()
    }

    @objc func countdown() {
        run(["open -a Terminal $HOME/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-countdown-terminal 2>/dev/null || $HOME/Wonderland/bin/wl chaos countdown"])
    }

    @objc func resetChaos() {
        run([
            "$HOME/Wonderland/bin/wl chaos reset",
            "$HOME/Wonderland/bin/wl visual-chaos write-contract"
        ])
        refresh()
    }

    @objc func panic() {
        run(["$HOME/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-panic --force 'Menubar Panic'"])
        refresh()
    }

    @objc func openChaosFolder() {
        run(["open $HOME/Wonderland/vault/chaos"])
    }

    @objc func openContract() {
        run(["open $HOME/Wonderland/vault/chaos/visual-chaos-contract.json"])
    }

    @objc func openGovernance() {
        run(["open $HOME/Wonderland/vault/08-Operations/reports/chaos-governance-report.json"])
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

cat > "$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-countdown-terminal" <<'SH'
#!/usr/bin/env bash
"$HOME/Wonderland/bin/wl" chaos countdown
read -r -p "Press Return to close..."
SH

chmod +x "$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-countdown-terminal"

cd "$APP_ROOT"
swift build -c release

cp ".build/release/wl-chaos-menubar" "$BIN"

cat > "$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-menubar" <<SH
#!/usr/bin/env bash
exec "$BIN"
SH

chmod +x "$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-menubar"

echo "PASS built wl-chaos-menubar"
echo "Run:"
echo "  ~/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar"
