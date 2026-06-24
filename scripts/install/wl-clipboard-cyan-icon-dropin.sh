#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/Workshop/apps/wl-clipboard"
SRC="$APP/Sources/WLClipboard/main.swift"
LABEL="com.wonderland.wl-clipboard"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
BACKUP="$SRC.bak.$(date +%Y%m%d-%H%M%S)"

cd "$APP"

cp "$SRC" "$BACKUP"

python3 <<'PY'
from pathlib import Path

p = Path("Sources/WLClipboard/main.swift")
s = p.read_text()

start = s.find("    @MainActor\n    func wlSetClipboardIcon")
if start == -1:
    start = s.find("    func wlSetClipboardIcon")

end = s.find("\n    func applicationDidFinishLaunching", start)
if start == -1 or end == -1:
    raise SystemExit("FAIL could not find wlSetClipboardIcon block")

replacement = r'''    @MainActor
    func wlSetClipboardIcon(_ symbol: String = "doc.on.clipboard.fill") {
        statusItem.button?.title = ""

        guard let sf = NSImage(
            systemSymbolName: symbol,
            accessibilityDescription: "WL Clipboard"
        ) else {
            return
        }

        let size = NSSize(width: 18, height: 18)
        let img = NSImage(size: size)

        img.lockFocus()

        let rect = NSRect(origin: .zero, size: size)

        sf.draw(
            in: rect,
            from: .zero,
            operation: .sourceOver,
            fraction: 1.0
        )

        NSColor(
            calibratedRed: 0.0,
            green: 229.0 / 255.0,
            blue: 255.0 / 255.0,
            alpha: 1.0
        ).set()

        rect.fill(using: .sourceAtop)

        img.unlockFocus()
        img.isTemplate = false

        statusItem.button?.image = img
        statusItem.button?.contentTintColor = nil
    }

'''

s = s[:start] + replacement + s[end:]
p.write_text(s)
PY

rm -rf .build
find Sources -name "*.bak.*" -print -delete

swift build -c release

launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl kickstart -k "gui/$(id -u)/$LABEL"

echo
echo "== verify =="
grep -n "wlSetClipboardIcon\|sourceAtop\|00E5FF\|229.0" "$SRC" || true
launchctl print "gui/$(id -u)/$LABEL" | grep -E 'state|program|properties|pid'

echo
echo "PASS cyan clipboard icon drop-in applied"
echo "Backup: $BACKUP"
