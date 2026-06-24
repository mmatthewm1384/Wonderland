#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Wonderland"
BIN="$ROOT/Wonderland-v4/ephemeral/bin"
CHAOS="$ROOT/vault/chaos"
PLIST="$HOME/Library/LaunchAgents/com.wonderland.chaos-watchdog.plist"

mkdir -p "$HOME/Library/LaunchAgents" "$CHAOS"

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
    <string>$BIN/wl-chaos-watchdog</string>
    <string>up</string>
  </array>

  <key>EnvironmentVariables</key>
  <dict>
    <key>WL_ROOT</key>
    <string>$ROOT</string>
    <key>PATH</key>
    <string>$BIN:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
  </dict>

  <key>RunAtLoad</key>
  <true/>

  <key>StandardOutPath</key>
  <string>$CHAOS/launchd.out.log</string>

  <key>StandardErrorPath</key>
  <string>$CHAOS/launchd.err.log</string>

  <key>WorkingDirectory</key>
  <string>$ROOT</string>
</dict>
</plist>
EOF

chmod 644 "$PLIST"

python3 - <<'PY'
import json
from datetime import datetime, timezone
from pathlib import Path

root = Path.home() / "Wonderland"
chaos = root / "vault" / "chaos"
aether = chaos / "chaos-aether.json"
chaos.mkdir(parents=True, exist_ok=True)

visuals = [
    "wave-agitator",
    "matrix-atom-slam",
    "counter-rotate-city-wave",
    "slam-waste-eliminator",
]

now = datetime.now(timezone.utc).isoformat()

record = {}
if aether.exists():
    try:
        record = json.loads(aether.read_text())
    except Exception:
        record = {}

record.update({
    "version": "1.4",
    "mode": "permanent_high_chaos",
    "last_reapplied": record.get("last_reapplied") or now,
    "escalated_visuals": record.get("escalated_visuals") or visuals,
    "visuals": record.get("visuals") or visuals,
    "threshold_hours": record.get("threshold_hours", 6),
    "retrigger_interval_min": record.get("retrigger_interval_min", 30),
})

record.setdefault("activated_at", now)

aether.write_text(json.dumps(record, indent=2, sort_keys=True))
print(f"normalized aether: {aether}")
PY

launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl enable "gui/$(id -u)/com.wonderland.chaos-watchdog"
launchctl kickstart -k "gui/$(id -u)/com.wonderland.chaos-watchdog"

echo "PASS launchd installed:"
echo "$PLIST"
