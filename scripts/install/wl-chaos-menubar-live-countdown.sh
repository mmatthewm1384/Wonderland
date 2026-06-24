#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APP_ROOT="$ROOT/apps/macos/wl-chaos-menubar"
SRC="$APP_ROOT/Sources/wl-chaos-menubar"
MAIN="$SRC/main.swift"
BACKUPS="$APP_ROOT/backups"
WRAP="$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-menubar"
LOG="$ROOT/vault/chaos/menubar.log"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUPS" "$ROOT/vault/chaos"

cp "$MAIN" "$BACKUPS/main.swift.backup.$STAMP"

python3 - "$MAIN" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

if "WL_LIVE_COUNTDOWN_MENU" not in s:
    s = s.replace(
        'var lastMessage = "Ready"\n    var lastCountdown = ""\n    var lastActionAt = ""',
        '''var lastMessage = "Ready"
    var lastCountdown = ""
    var countdownDisplay = "Unknown"
    var lastActionAt = ""'''
    )

    s = s.replace(
        'func refresh() {',
        '''// WL_LIVE_COUNTDOWN_MENU
    func formatCountdown(_ raw: String) -> String {
        let cleaned = raw
            .replacingOccurrences(of: "h", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let hoursValue = Double(cleaned) else {
            return raw
        }

        let totalMinutes = max(0, Int(hoursValue * 60))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        return "\\(hours)h \\(String(format: "%02d", minutes))m"
    }

    func updateCountdown() {
        let output = shell("\\(chaosBin)/wl-chaos-watchdog countdown")

        if let line = output
            .components(separatedBy: "\\n")
            .first(where: { $0.contains("Escalation in:") }) {

            let raw = line
                .replacingOccurrences(of: "Escalation in:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            countdownDisplay = formatCountdown(raw)
        } else {
            countdownDisplay = "Unavailable"
        }
    }

    func refresh() {'''
    )

    s = s.replace(
        'item.button?.attributedTitle = wlStatusTitle("◉ WL", color: wlCyan)\n        refresh()',
        'item.button?.attributedTitle = wlStatusTitle("◉ WL", color: wlCyan)\n        updateCountdown()\n        refresh()'
    )

    s = s.replace(
        'Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in\n            self.refresh()\n        }',
        '''Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.updateCountdown()
            self.refresh()
        }'''
    )

    s = s.replace(
        '''menu.addItem(disabled(watchdogRunning() ? "Watchdog: running" : "Watchdog: stopped"))

        if !lastCountdown.isEmpty {''',
        '''menu.addItem(disabled(watchdogRunning() ? "Watchdog: running" : "Watchdog: stopped"))

        menu.addItem(.separator())
        menu.addItem(disabled("Escalation In"))
        menu.addItem(disabled(countdownDisplay))

        if !lastCountdown.isEmpty {'''
    )

    s = s.replace(
        '''@objc func checkIn() {
        let output = shell("\\(chaosBin)/wl-chaos-watchdog checkin")
        mark(output.components(separatedBy: "\\n").last ?? "Check-in complete")
    }''',
        '''@objc func checkIn() {
        let output = shell("\\(chaosBin)/wl-chaos-watchdog checkin")
        updateCountdown()
        mark(output.components(separatedBy: "\\n").last ?? "Check-in complete")
    }'''
    )

p.write_text(s)
PY

# Keep SwiftPM clean.
mv "$SRC"/*.backup.* "$BACKUPS"/ 2>/dev/null || true

cd "$APP_ROOT"
swift build -c release

cp "$APP_ROOT/.build/release/wl-chaos-menubar" "$APP_ROOT/build/wl-chaos-menubar"

pkill -f wl-chaos-menubar 2>/dev/null || true
nohup "$WRAP" > "$LOG" 2>&1 &

echo "PASS live countdown installed"
echo "Backup: $BACKUPS/main.swift.backup.$STAMP"
echo "Log: $LOG"
