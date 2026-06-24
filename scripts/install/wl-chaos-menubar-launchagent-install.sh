#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
BIN="$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-menubar"
PLIST="$HOME/Library/LaunchAgents/com.wonderland.chaos-menubar.plist"
LOG_DIR="$ROOT/vault/chaos"
OUT="$LOG_DIR/menubar.launchd.out.log"
ERR="$LOG_DIR/menubar.launchd.err.log"

mkdir -p "$HOME/Library/LaunchAgents" "$LOG_DIR"

if [[ ! -x "$BIN" ]]; then
  echo "FAIL missing executable: $BIN"
  exit 1
fi

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.wonderland.chaos-menubar</string>

  <key>ProgramArguments</key>
  <array>
    <string>$BIN</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <true/>

  <key>StandardOutPath</key>
  <string>$OUT</string>

  <key>StandardErrorPath</key>
  <string>$ERR</string>

  <key>WorkingDirectory</key>
  <string>$ROOT</string>
</dict>
</plist>
EOF

chmod 644 "$PLIST"

launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl enable "gui/$(id -u)/com.wonderland.chaos-menubar"
launchctl kickstart -k "gui/$(id -u)/com.wonderland.chaos-menubar"

echo "PASS installed chaos menubar LaunchAgent"
echo "$PLIST"
