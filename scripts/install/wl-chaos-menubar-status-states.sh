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

if "WL_STATUS_ICON_STATES" not in s:
    s = s.replace(
        'let wlGreen = NSColor(calibratedRed: 0x00/255, green: 0xFF/255, blue: 0x66/255, alpha: 1.0)',
        '''let wlGreen = NSColor(calibratedRed: 0x00/255, green: 0xFF/255, blue: 0x66/255, alpha: 1.0)
let wlRed = NSColor(calibratedRed: 0xFF/255, green: 0x2A/255, blue: 0x4F/255, alpha: 1.0)'''
    )

    s = s.replace(
        'func refresh() {',
        '''// WL_STATUS_ICON_STATES
    func updateStatusIcon() {
        if !watchdogRunning() {
            item.button?.attributedTitle = wlStatusTitle("◉ FAIL", color: wlRed)
            return
        }

        if let h = countdownHours, h <= 0.25 {
            item.button?.attributedTitle = wlStatusTitle("◉ SOON", color: wlGreen)
            return
        }

        if chaosActive() {
            item.button?.attributedTitle = wlStatusTitle("◉ CHAOS", color: wlPurple)
            return
        }

        item.button?.attributedTitle = wlStatusTitle("◉ WL", color: wlCyan)
    }

    func refresh() {'''
    )

    s = s.replace(
        'item.button?.attributedTitle = chaosActive() ? wlStatusTitle("◉ CHAOS", color: wlPurple) : wlStatusTitle("◉ WL", color: wlCyan)',
        'updateStatusIcon()'
    )

p.write_text(s)
PY

mv "$SRC"/*.backup.* "$BACKUPS"/ 2>/dev/null || true

cd "$APP_ROOT"
swift build -c release

cp "$APP_ROOT/.build/release/wl-chaos-menubar" "$APP_ROOT/build/wl-chaos-menubar"

pkill -f wl-chaos-menubar 2>/dev/null || true
nohup "$WRAP" > "$LOG" 2>&1 &

echo "PASS status icon states installed"
echo "Backup: $BACKUPS/main.swift.backup.$STAMP"
