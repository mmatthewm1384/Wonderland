#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APP_ROOT="$ROOT/apps/macos/wl-chaos-menubar"
MAIN="$APP_ROOT/Sources/wl-chaos-menubar/main.swift"
WRAP="$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-menubar"
STAMP="$(date +%Y%m%d-%H%M%S)"

cp "$MAIN" "$MAIN.backup.$STAMP"

python3 - "$MAIN" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

if "WL_PALETTE_MENU_INDICATOR" not in s:
    marker = 'import Foundation\n'
    inject = '''
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
'''
    s = s.replace(marker, marker + inject, 1)

# Replace direct title assignments with attributed title helper.
s = s.replace(
    'item.button?.title = "☄︎ WL"',
    'item.button?.attributedTitle = wlStatusTitle("◉ WL", color: wlCyan)'
)

s = s.replace(
    'item.button?.title = chaosActive() ? "☄︎ CHAOS" : "☄︎ WL"',
    'item.button?.attributedTitle = chaosActive() ? wlStatusTitle("◉ CHAOS", color: wlPurple) : wlStatusTitle("◉ WL", color: wlCyan)'
)

p.write_text(s)
PY

cd "$APP_ROOT"
swift build -c release

cp "$APP_ROOT/.build/release/wl-chaos-menubar" "$APP_ROOT/build/wl-chaos-menubar"

pkill -f wl-chaos-menubar 2>/dev/null || true

nohup "$WRAP" > "$ROOT/vault/chaos/menubar.log" 2>&1 &

echo "PASS colored indicator installed"
echo "Backup: $MAIN.backup.$STAMP"
