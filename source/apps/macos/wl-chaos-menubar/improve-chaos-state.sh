#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
APP="$WL_HOME/apps/macos/wl-chaos-menubar"
SRC="$APP/Sources/wl-chaos-menubar/main.swift"
BACKUP="$APP/backups/main.swift.backup.$(date +%Y%m%d-%H%M%S)-state-driven"

mkdir -p "$APP/backups" "$WL_HOME/vault/chaos"
cp "$SRC" "$BACKUP"

python3 - <<'PY'
from pathlib import Path
import re

p = Path.home() / "Wonderland/apps/macos/wl-chaos-menubar/Sources/wl-chaos-menubar/main.swift"
s = p.read_text()

# 1. Single authority: chaosActive follows aetherActive.
s = re.sub(
    r'func chaosActive\(\) -> Bool \{.*?\}',
    'func chaosActive() -> Bool {\n    aetherActive()\n}',
    s,
    flags=re.S
)

# 2. Make aetherActive explicit and stable.
s = re.sub(
    r'func aetherActive\(\) -> Bool \{.*?\}',
    'func aetherActive() -> Bool {\n    readFile(aetherPath).contains("permanent_high_chaos")\n}',
    s,
    flags=re.S
)

# 3. Ensure menu glyph refresh line is authoritative.
s = re.sub(
    r'item\.button\?\.attributedTitle = chaosActive\(\) \? wlStatusTitle\("◉ CHAOS", color: wlPurple\) : wlStatusTitle\("◉ WL", color: wlCyan\)',
    'item.button?.attributedTitle = chaosActive() ? wlStatusTitle("◉ CHAOS", color: wlPurple) : wlStatusTitle("◉ WL", color: wlCyan)',
    s
)

# 4. Add refresh helper if missing.
if "func refreshStatus()" not in s:
    helper = '''
    func refreshStatus() {
        item.button?.attributedTitle = chaosActive() ? wlStatusTitle("◉ CHAOS", color: wlPurple) : wlStatusTitle("◉ WL", color: wlCyan)
        updateActivityAges()
        updateContractPreview()
        updateRecentActivity()
    }

'''
    s = s.replace("    func updateCountdown()", helper + "    func updateCountdown()", 1)

# 5. Refresh after countdown updates if not already there.
if "refreshStatus()" in s and "self.refreshStatus()" not in s:
    s = s.replace("self.updateCountdown()", "self.updateCountdown()\n            self.refreshStatus()", 1)

# 6. Make panic action create chaos marker and refresh immediately.
start = s.find("    @objc func panic() {")
if start != -1:
    brace = 0
    end = None
    for i in range(start, len(s)):
        if s[i] == "{":
            brace += 1
        elif s[i] == "}":
            brace -= 1
            if brace == 0:
                end = i + 1
                break

    if end:
        new_func = '''    @objc func panic() {
        let alert = NSAlert()
        alert.messageText = "Wonderland Panic"
        alert.informativeText = "Start Chaos Mode now?"
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Panic")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            let output = shell("/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-panic --yes --reason=menubar-panic")
            mark(output.components(separatedBy: "\\\\n").last ?? "CHAOS MODE ACTIVE")
            refreshStatus()
        }
    }'''
        s = s[:start] + new_func + s[end:]

p.write_text(s)
PY

cd "$APP"
swift build -c release
cp "$APP/.build/release/wl-chaos-menubar" "$APP/build/wl-chaos-menubar"
chmod +x "$APP/build/wl-chaos-menubar"

launchctl bootout "gui/$(id -u)/com.wonderland.chaos-menubar" 2>/dev/null || true
pkill -f wl-chaos-menubar 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.wonderland.chaos-menubar.plist"

echo "PASS improved chaos menubar"
echo "backup: $BACKUP"
