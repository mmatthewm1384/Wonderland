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

if "WL_RECENT_ACTIVITY_MENU" not in s:
    s = s.replace(
        'let reportPath = wlRoot + "/vault/08-Operations/reports/chaos-governance-report.json"',
        '''let reportPath = wlRoot + "/vault/08-Operations/reports/chaos-governance-report.json"
let runsLogPath = wlRoot + "/vault/ephemeral-runs.log"'''
    )

    s = s.replace(
        'var lastActionAt = ""',
        '''var lastActionAt = ""
    var recentActivity: [String] = []'''
    )

    s = s.replace(
        'func refresh() {',
        '''// WL_RECENT_ACTIVITY_MENU
    func updateRecentActivity() {
        let raw = readFile(runsLogPath)
        let lines = raw
            .split(separator: "\\n")
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

    func refresh() {'''
    )

    s = s.replace(
        '''item.button?.attributedTitle = chaosActive() ? wlStatusTitle("◉ CHAOS", color: wlPurple) : wlStatusTitle("◉ WL", color: wlCyan)
        buildMenu()''',
        '''item.button?.attributedTitle = chaosActive() ? wlStatusTitle("◉ CHAOS", color: wlPurple) : wlStatusTitle("◉ WL", color: wlCyan)
        updateRecentActivity()
        buildMenu()'''
    )

    s = s.replace(
        '''menu.addItem(.separator())
        menu.addItem(disabled("Last: \\(lastMessage)"))''',
        '''menu.addItem(.separator())
        menu.addItem(disabled("Recent Activity"))

        if recentActivity.isEmpty {
            menu.addItem(disabled("No recent events"))
        } else {
            for event in recentActivity.prefix(5) {
                menu.addItem(disabled("• \\(event)"))
            }
        }

        menu.addItem(.separator())
        menu.addItem(disabled("Last: \\(lastMessage)"))'''
    )

p.write_text(s)
PY

mv "$SRC"/*.backup.* "$BACKUPS"/ 2>/dev/null || true

cd "$APP_ROOT"
swift build -c release

cp "$APP_ROOT/.build/release/wl-chaos-menubar" "$APP_ROOT/build/wl-chaos-menubar"

pkill -f wl-chaos-menubar 2>/dev/null || true
nohup "$WRAP" > "$LOG" 2>&1 &

echo "PASS recent activity installed"
echo "Backup: $BACKUPS/main.swift.backup.$STAMP"
