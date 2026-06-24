#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
WATCH="$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-watchdog"
CHAOS_PY="$ROOT/Wonderland-v4/ephemeral/chaos-watchdog/chaos_watchdog.py"
SKHD="$HOME/.skhdrc"
STAMP="$(date +%Y%m%d-%H%M%S)"

cp "$WATCH" "$WATCH.backup.$STAMP"
cp "$CHAOS_PY" "$CHAOS_PY.backup.$STAMP"
cp "$SKHD" "$SKHD.backup.$STAMP"

python3 - "$CHAOS_PY" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

if "operator_checkin" not in s:
    insert = r'''
def operator_checkin():
    append_event("operator_checkin", {"source": "manual"})
    write_log("Operator check-in recorded; inactivity timer reset")


def countdown():
    threshold = float(os.environ.get("CHAOS_THRESHOLD_HOURS", "6"))
    last = last_activity()
    if last is None:
        print("No activity recorded.")
        print(f"Threshold: {threshold}h")
        print("Escalation: eligible now")
        return

    age_hours = (utc() - last).total_seconds() / 3600
    remaining = max(0, threshold - age_hours)

    print(f"Threshold: {threshold:.2f}h")
    print(f"Last activity: {age_hours:.2f}h ago")
    print(f"Escalation in: {remaining:.2f}h")
    print(f"Escalation eligible: {'YES' if remaining <= 0 else 'NO'}")
'''
    s = s.replace('def status_once():', insert + '\ndef status_once():')

if 'elif cmd == "checkin":' not in s:
    s = s.replace(
'''    elif cmd == "reset":
        reset()
    elif cmd == "escalate":
        escalate("manual")
''',
'''    elif cmd == "reset":
        reset()
    elif cmd == "checkin":
        operator_checkin()
    elif cmd == "countdown":
        countdown()
    elif cmd == "escalate":
        escalate("manual")
'''
    )

p.write_text(s)
PY

python3 - "$WATCH" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

if "  checkin)" not in s:
    s = s.replace(
'''  aether-status)
    python3 "$WATCH" aether-status
    ;;
  escalate)
    python3 "$WATCH" escalate
    ;;
''',
'''  aether-status)
    python3 "$WATCH" aether-status
    ;;
  checkin)
    python3 "$WATCH" checkin
    ;;
  countdown)
    python3 "$WATCH" countdown
    ;;
  escalate)
    python3 "$WATCH" escalate
    ;;
'''
    )

s = s.replace(
'up|down|status|doctor|logs|repair|reset|aether-status|escalate',
'up|down|status|doctor|logs|repair|reset|aether-status|checkin|countdown|escalate'
)

p.write_text(s)
PY

cat >> "$SKHD" <<'EOF'

# Wonderland Chaos Check-In Hotkey
# Resets inactivity timer without changing mode
cmd + ctrl + alt + shift - i : export PATH="$HOME/Wonderland/Wonderland-v4/ephemeral/bin:$PATH"; wl chaos checkin

# Wonderland Chaos Countdown Hotkey
# Logs/display countdown in terminal context when skhd can surface it
cmd + ctrl + alt + shift - t : export PATH="$HOME/Wonderland/Wonderland-v4/ephemeral/bin:$PATH"; wl chaos countdown
EOF

chmod +x "$WATCH" "$CHAOS_PY"
skhd --reload 2>/dev/null || true

echo "PASS installed chaos checkin/countdown"
echo "Backups:"
echo "  $WATCH.backup.$STAMP"
echo "  $CHAOS_PY.backup.$STAMP"
echo "  $SKHD.backup.$STAMP"
