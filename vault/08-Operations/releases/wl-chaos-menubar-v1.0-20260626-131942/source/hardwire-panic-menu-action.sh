#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
APP="$WL_HOME/apps/macos/wl-chaos-menubar"
SRC="$APP/Sources/wl-chaos-menubar/main.swift"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$APP/backups/main.swift.backup.$STAMP"

mkdir -p "$APP/backups" "$WL_HOME/vault/chaos"
cp "$SRC" "$BACKUP"

python3 - "$SRC" <<'PY'
from pathlib import Path
import re
import sys

p = Path(sys.argv[1])
s = p.read_text()

new_body = r'''    @objc func panic() {
        let alert = NSAlert()
        alert.messageText = "Wonderland Panic"
        alert.informativeText = "Enter panic mode now?"
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Panic")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            let output = shell("/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-panic --yes --reason=menubar-panic")
            _ = shell("echo '[\\(Date())] panic menu clicked' >> /Users/wonderland/Wonderland/vault/chaos/menubar.actions.log")
            mark(output.components(separatedBy: "\n").last ?? "Panic mode active")
        }
    }'''

s = re.sub(
    r'    @objc func panic\(\) \{.*?    \}\n\n    @objc func openChaosFolder',
    new_body + "\n\n    @objc func openChaosFolder",
    s,
    flags=re.S,
)

p.write_text(s)
PY

cd "$APP"
swift build -c release

cp "$APP/.build/release/wl-chaos-menubar" "$APP/build/wl-chaos-menubar"
chmod +x "$APP/build/wl-chaos-menubar"

launchctl bootout "gui/$(id -u)/com.wonderland.chaos-menubar" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.wonderland.chaos-menubar.plist"
launchctl kickstart -k "gui/$(id -u)/com.wonderland.chaos-menubar"

echo "backup: $BACKUP"
echo "PASS hardwired panic menu action"
grep -n "wl-chaos-panic\|menubar.actions.log" "$SRC"
