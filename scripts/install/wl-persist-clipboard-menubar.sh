#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
LABEL="com.wonderland.clipboard-menubar"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOGDIR="$WL_HOME/logs/launchd"

mkdir -p "$LOGDIR" "$HOME/Library/LaunchAgents"

echo "== finding clipboard menubar app =="

CANDIDATE="$(
  find "$WL_HOME" "$HOME/Applications" /Applications \
    -iname "*clipboard*" -o \
    -iname "*clip*" -o \
    -iname "*paste*" 2>/dev/null |
  grep -Ei 'menubar|menu|clipboard|clip|paste' |
  head -1
)"

if [[ -z "${CANDIDATE:-}" ]]; then
  echo "FAIL no clipboard menubar candidate found"
  exit 1
fi

echo "FOUND: $CANDIDATE"

if [[ "$CANDIDATE" == *.app ]]; then
  EXEC="/usr/bin/open"
  ARGS="<string>-a</string><string>$CANDIDATE</string>"
else
  chmod +x "$CANDIDATE"
  EXEC="$CANDIDATE"
  ARGS=""
fi

launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>

  <key>ProgramArguments</key>
  <array>
    <string>$EXEC</string>
    $ARGS
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <true/>

  <key>WorkingDirectory</key>
  <string>$WL_HOME</string>

  <key>StandardOutPath</key>
  <string>$LOGDIR/clipboard-menubar.out.log</string>

  <key>StandardErrorPath</key>
  <string>$LOGDIR/clipboard-menubar.err.log</string>
</dict>
</plist>
PLIST

plutil -lint "$PLIST"
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl kickstart -k "gui/$(id -u)/$LABEL"

echo
echo "== status =="
launchctl print "gui/$(id -u)/$LABEL" | head -60
echo
echo "PASS clipboard menubar persistence installed"
