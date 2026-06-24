#!/usr/bin/env bash
set -euo pipefail

PLIST="$HOME/Library/LaunchAgents/com.wonderland.wl-clipboard.plist"

echo "== locate clipboard source =="
plutil -p "$PLIST"

APP_PATH="$(plutil -p "$PLIST" | grep -Eo '/[^"]+' | grep -E 'wl-clipboard|MidnightClip|clipboard|menubar' | head -1 || true)"
echo "candidate: ${APP_PATH:-unknown}"

echo
echo "== patch likely Swift sources =="
grep -RIl 'NSStatusBar\|statusItem\|clipboard\|pasteboard\|doc.on.clipboard\|clipboard' \
  "$HOME/Wonderland" "$HOME/Projects" 2>/dev/null |
grep -Ei 'clipboard|menubar|MidnightClip|shredclip|wl-' |
while read -r f; do
  cp "$f" "$f.bak.$(date +%Y%m%d-%H%M%S)"
  perl -0pi -e '
    s/NSImage\(systemSymbolName:\s*"[^"]*clipboard[^"]*"\s*,\s*accessibilityDescription:\s*[^)]*\)/NSImage(systemSymbolName: "doc.on.clipboard.fill", accessibilityDescription: "WL Clipboard")/g;
    s/systemSymbolName:\s*"[^"]*clipboard[^"]*"/systemSymbolName: "doc.on.clipboard.fill"/g;
    s/statusItem\.button\?\.title\s*=\s*"[^"]*"/statusItem.button?.title = ""/g;
    s/\.isTemplate\s*=\s*true/.isTemplate = false/g;
  ' "$f"
done

echo
echo "== rebuild known project if present =="
if [[ -d "$HOME/Library/Containers/com.matthewmahaney.MidnightClip" ]]; then
  echo "MidnightClip container exists"
fi

if [[ -d "$HOME/Workshop/apps/macos/wl-clipboard" ]]; then
  cd "$HOME/Workshop/apps/macos/wl-clipboard"
  swift build -c release || true
fi

if [[ -d "$HOME/Workshop/apps/macos/wl-menubar-clipboard" ]]; then
  cd "$HOME/Workshop/apps/macos/wl-menubar-clipboard"
  swift build -c release || true
fi

echo
echo "== restart persistent agent =="
launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl kickstart -k "gui/$(id -u)/com.wonderland.wl-clipboard"

echo
echo "== verify =="
launchctl print "gui/$(id -u)/com.wonderland.wl-clipboard" | head -80
echo "PASS clipboard icon patch attempted"
