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

# Remove no-usage Swift warnings.
s = s.replace('shell("open \'\\(chaosDir)\'")', '_ = shell("open \'\\(chaosDir)\'")')
s = s.replace('shell("open \'\\(contractPath)\'")', '_ = shell("open \'\\(contractPath)\'")')
s = s.replace('shell("open \'\\(reportPath)\'")', '_ = shell("open \'\\(reportPath)\'")')

if "WL_COUNTDOWN_COLOR_STATE" not in s:
    s = s.replace(
        'var countdownDisplay = "Unknown"\n    var lastActionAt = ""',
        '''var countdownDisplay = "Unknown"
    var countdownHours: Double? = nil
    var lastActionAt = ""'''
    )

    s = s.replace(
        '''func formatCountdown(_ raw: String) -> String {
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
    }''',
        '''// WL_COUNTDOWN_COLOR_STATE
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

        return "\\(hours)h \\(String(format: "%02d", minutes))m"
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
    }'''
    )

    s = s.replace(
        '''menu.addItem(disabled("Escalation In"))
        menu.addItem(disabled(countdownDisplay))''',
        '''menu.addItem(disabled("Escalation In"))
        menu.addItem(coloredDisabled(countdownDisplay, color: countdownColor()))'''
    )

p.write_text(s)
PY

mv "$SRC"/*.backup.* "$BACKUPS"/ 2>/dev/null || true

cd "$APP_ROOT"
swift build -c release

cp "$APP_ROOT/.build/release/wl-chaos-menubar" "$APP_ROOT/build/wl-chaos-menubar"

pkill -f wl-chaos-menubar 2>/dev/null || true
nohup "$WRAP" > "$LOG" 2>&1 &

echo "PASS countdown colors installed"
echo "Backup: $BACKUPS/main.swift.backup.$STAMP"
