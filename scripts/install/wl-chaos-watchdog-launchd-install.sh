#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
EPH="$ROOT/Wonderland-v4/ephemeral"
BIN="$EPH/bin"
WATCHDOG="$BIN/wl-chaos-watchdog"
LAUNCHD_DIR="$HOME/Library/LaunchAgents"
PLIST="$LAUNCHD_DIR/com.wonderland.chaos-watchdog.plist"
LOG_DIR="$ROOT/vault/chaos"
OUT_LOG="$LOG_DIR/launchd.out.log"
ERR_LOG="$LOG_DIR/launchd.err.log"

mkdir -p "$BIN" "$LAUNCHD_DIR" "$LOG_DIR"

if [[ ! -x "$WATCHDOG" ]]; then
  echo "FAIL missing executable: $WATCHDOG"
  echo "Install wl-chaos-watchdog first."
  exit 1
fi

BACKUP="$WATCHDOG.backup.$(date +%Y%m%d-%H%M%S)"
cp "$WATCHDOG" "$BACKUP"

python3 - "$WATCHDOG" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

if "install-launchd)" in text:
    print("launchd commands already present")
    raise SystemExit(0)

needle = """  reset)
    "$0" down || true
    python3 "$WATCH" reset
    ;;
"""

insert = """  install-launchd)
    mkdir -p "$HOME/Library/LaunchAgents" "$CHAOS"
    PLIST="$HOME/Library/LaunchAgents/com.wonderland.chaos-watchdog.plist"

    cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.wonderland.chaos-watchdog</string>

  <key>ProgramArguments</key>
  <array>
    <string>$0</string>
    <string>up</string>
  </array>

  <key>EnvironmentVariables</key>
  <dict>
    <key>WL_ROOT</key>
    <string>$ROOT</string>
    <key>PATH</key>
    <string>$ROOT/Wonderland-v4/ephemeral/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
  </dict>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <false/>

  <key>StandardOutPath</key>
  <string>$CHAOS/launchd.out.log</string>

  <key>StandardErrorPath</key>
  <string>$CHAOS/launchd.err.log</string>

  <key>WorkingDirectory</key>
  <string>$ROOT</string>
</dict>
</plist>
EOF

    launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
    launchctl bootstrap "gui/$(id -u)" "$PLIST"
    launchctl enable "gui/$(id -u)/com.wonderland.chaos-watchdog"
    launchctl kickstart -k "gui/$(id -u)/com.wonderland.chaos-watchdog"

    echo "Installed LaunchAgent: $PLIST"
    ;;
  uninstall-launchd)
    PLIST="$HOME/Library/LaunchAgents/com.wonderland.chaos-watchdog.plist"
    launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
    rm -f "$PLIST"
    echo "Removed LaunchAgent: $PLIST"
    ;;
  launchd-status)
    PLIST="$HOME/Library/LaunchAgents/com.wonderland.chaos-watchdog.plist"
    echo "LaunchAgent plist: $PLIST"
    [[ -f "$PLIST" ]] && echo "plist: present" || echo "plist: missing"
    launchctl print "gui/$(id -u)/com.wonderland.chaos-watchdog" 2>/dev/null || echo "launchd: not loaded"
    ;;
  launchd-restart)
    PLIST="$HOME/Library/LaunchAgents/com.wonderland.chaos-watchdog.plist"
    if [[ ! -f "$PLIST" ]]; then
      echo "LaunchAgent missing. Run: wl-chaos-watchdog install-launchd"
      exit 1
    fi
    launchctl kickstart -k "gui/$(id -u)/com.wonderland.chaos-watchdog"
    echo "Restarted LaunchAgent"
    ;;
"""

if needle not in text:
    raise SystemExit("FAIL could not patch wl-chaos-watchdog command table")

text = text.replace(needle, needle + insert)

text = text.replace(
    'echo "Usage: wl-chaos-watchdog up|down|status|doctor|logs|repair|reset|aether-status|escalate"',
    'echo "Usage: wl-chaos-watchdog up|down|status|doctor|logs|repair|reset|aether-status|escalate|install-launchd|uninstall-launchd|launchd-status|launchd-restart"'
)

path.write_text(text)
print("patched wl-chaos-watchdog")
PY

chmod +x "$WATCHDOG"

echo "Installed launchd support."
echo "Backup: $BACKUP"
echo ""
echo "Next:"
echo "  wl-chaos-watchdog install-launchd"
echo "  wl-chaos-watchdog launchd-status"
