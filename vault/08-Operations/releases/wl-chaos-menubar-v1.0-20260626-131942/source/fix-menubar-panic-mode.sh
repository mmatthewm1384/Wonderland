#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
APP="$WL_HOME/apps/macos/wl-chaos-menubar"
SRC="$APP/Sources/wl-chaos-menubar/main.swift"
PANIC="$WL_HOME/Wonderland-v4/ephemeral/bin/wl-chaos-panic"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$APP/backups" "$WL_HOME/vault/chaos"

cp "$SRC" "$APP/backups/main.swift.backup.$STAMP"
cp "$PANIC" "$PANIC.backup.$STAMP"

cat > "$PANIC" <<'PANIC'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
AETHER="$WL_HOME/vault/chaos/aether"
LOG="$WL_HOME/vault/chaos/panic.log"
REASON="manual panic"
YES=0

mkdir -p "$(dirname "$LOG")"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|-y|--force) YES=1; shift ;;
    --reason=*) REASON="${1#--reason=}"; shift ;;
    --reason) REASON="${2:-menubar-panic}"; shift 2 ;;
    *) REASON="$1"; shift ;;
  esac
done

if [[ "$YES" != "1" ]]; then
  read -r -p "Emergency panic will stop watchdog and wipe aether. Continue? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || exit 1
fi

{
  echo "[$(date -Iseconds)] panic start: $REASON"
  launchctl bootout "gui/$(id -u)/com.wonderland.chaos-watchdog" 2>/dev/null || true
  pkill -f chaos_watchdog.py 2>/dev/null || true
  rm -rf "$AETHER"
  mkdir -p "$AETHER"
  chmod 700 "$AETHER"
  echo "[$(date -Iseconds)] panic complete"
} >> "$LOG" 2>&1

echo "Emergency panic complete. Aether cleared."
PANIC

chmod +x "$PANIC"

python3 - "$SRC" <<'PY'
from pathlib import Path
import re, sys

p = Path(sys.argv[1])
s = p.read_text()

# Replace any old panic shell invocation with the correct noninteractive command.
s = re.sub(
    r'let output = shell\("\\\(chaosBin\)/wl-chaos-panic[^"]*"\)',
    'let output = shell("\\(chaosBin)/wl-chaos-panic --yes --reason=menubar-panic")',
    s,
)

p.write_text(s)
PY

cd "$APP"
swift build -c release
mkdir -p "$APP/build"
cp "$APP/.build/release/wl-chaos-menubar" "$APP/build/wl-chaos-menubar"
chmod +x "$APP/build/wl-chaos-menubar"

launchctl bootout "gui/$(id -u)/com.wonderland.chaos-menubar" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.wonderland.chaos-menubar.plist"
launchctl kickstart -k "gui/$(id -u)/com.wonderland.chaos-menubar"

echo "PASS rebuilt and restarted"
grep -n "wl-chaos-panic" "$SRC"
echo "Now click Panic in the menubar, confirm the dialog, then run:"
echo "tail -10 $WL_HOME/vault/chaos/panic.log"
