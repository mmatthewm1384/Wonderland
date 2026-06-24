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

if "WL_DRILL_MENU_ACTION" not in s:
    s = s.replace(
        'menu.addItem(action("Governance Check", #selector(governance)))',
        '''menu.addItem(action("Governance Check", #selector(governance)))
        menu.addItem(action("Recovery Drill", #selector(recoveryDrill)))'''
    )

    s = s.replace(
        '''@objc func governance() {
        let output = shell("python3 \\(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
        lastCountdown = output
        mark(output.contains("RESULT PASS") ? "Governance PASS" : "Governance FAIL")
    }''',
        '''@objc func governance() {
        let output = shell("python3 \\(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
        lastCountdown = output
        mark(output.contains("RESULT PASS") ? "Governance PASS" : "Governance FAIL")
    }

    // WL_DRILL_MENU_ACTION
    @objc func recoveryDrill() {
        let output = shell("\\(wlRoot)/bin/wl-chaos-drill")
        lastCountdown = output
        updateCountdown()
        updateContractPreview()
        updateActivityAges()
        updateRecentActivity()
        mark(output.contains("RESULT PASS") ? "Recovery Drill PASS" : "Recovery Drill FAIL")
    }'''
    )

p.write_text(s)
PY

mv "$SRC"/*.backup.* "$BACKUPS"/ 2>/dev/null || true

cd "$APP_ROOT"
swift build -c release
cp "$APP_ROOT/.build/release/wl-chaos-menubar" "$APP_ROOT/build/wl-chaos-menubar"

launchctl kickstart -k "gui/$(id -u)/com.wonderland.chaos-menubar" 2>/dev/null || {
  pkill -f wl-chaos-menubar 2>/dev/null || true
  nohup "$WRAP" > "$LOG" 2>&1 &
}

echo "PASS added Recovery Drill menu action"
echo "Backup: $BACKUPS/main.swift.backup.$STAMP"
