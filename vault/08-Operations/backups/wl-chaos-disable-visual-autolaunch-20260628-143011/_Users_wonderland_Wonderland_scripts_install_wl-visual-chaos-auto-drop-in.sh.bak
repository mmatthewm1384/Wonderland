#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
EPH="$ROOT/Wonderland-v4/ephemeral"
BIN="$EPH/bin"
WATCH="$EPH/chaos-watchdog/chaos_watchdog.py"
MANAGER="$EPH/ephemeral_manager.py"
CHAOS="$ROOT/vault/chaos"

mkdir -p "$BIN" "$CHAOS"

cat > "$BIN/wl-visual-chaos" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
CHAOS="$ROOT/vault/chaos"
CONTRACT="$CHAOS/visual-chaos-contract.json"
AETHER="$CHAOS/chaos-aether.json"

mkdir -p "$CHAOS"

write_contract() {
python3 - "$CONTRACT" "$AETHER" <<'PY'
import json, sys
from datetime import datetime, timezone
from pathlib import Path

contract = Path(sys.argv[1])
aether = Path(sys.argv[2])
active = aether.exists()
now = datetime.now(timezone.utc).isoformat()

payload = {
  "version": "1.0",
  "updated_at": now,
  "chaos_active": active,
  "apps": {
    "wl-spin-city": {
      "rings": 5 if active else 3,
      "rotation_speed": 2.0 if active else 1.0,
      "easing": "extreme" if active else "normal",
      "jitter": 2.0 if active else 0.35
    },
    "wl-agitate": {
      "intensity": 2.0 if active else 0.6,
      "mode": "hybrid-max-jitter" if active else "normal",
      "trail_decay": "slow" if active else "normal"
    },
    "wl-matrix": {
      "particles": 10000 if active else 1200,
      "living_ratio": 0.9 if active else 0.35,
      "waste_decay": "slow" if active else "normal",
      "slam_force": 2.0 if active else 0.7
    }
  }
}

contract.write_text(json.dumps(payload, indent=2, sort_keys=True))
print(contract)
PY
}

launch_app() {
  local app="$1"
  if [[ -d "$app" ]]; then
    open "$app" || true
  else
    echo "WARN missing app: $app"
  fi
}

case "${1:-status}" in
  write-contract)
    write_contract
    ;;
  launch-all)
    write_contract >/dev/null
    export WL_CHAOS_CONTRACT="$CONTRACT"
    export WL_CHAOS_ACTIVE=true
    launch_app "$ROOT/apps/macos/Spin City Wave.app"
    launch_app "$ROOT/apps/macos/Agitate Waves.app"
    launch_app "$ROOT/apps/macos/Matrix Atom Destroyer.app"
    ;;
  status)
    write_contract >/dev/null
    cat "$CONTRACT"
    ;;
  *)
    echo "Usage: wl-visual-chaos write-contract|launch-all|status"
    exit 2
    ;;
esac
SH

chmod +x "$BIN/wl-visual-chaos"

if [[ -f "$WATCH" ]] && ! grep -q "wl-visual-chaos" "$WATCH"; then
  cp "$WATCH" "$WATCH.backup.$(date +%Y%m%d-%H%M%S)"

  python3 - "$WATCH" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

needle = 'manager_launch("chaos-escalator", chaos=True)'
replacement = '''manager_launch("chaos-escalator", chaos=True)
    subprocess.run([str(BIN / "wl-visual-chaos"), "launch-all"], check=False)'''

s = s.replace(needle, replacement)
p.write_text(s)
PY

  chmod +x "$WATCH"
fi

if [[ -f "$MANAGER" ]] && ! grep -q "wl-visual-chaos" "$MANAGER"; then
  cp "$MANAGER" "$MANAGER.backup.$(date +%Y%m%d-%H%M%S)"

  python3 - "$MANAGER" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

if "import subprocess" not in s:
    s = s.replace("import argparse, json, math, random, shutil, tempfile", "import argparse, json, math, random, shutil, tempfile, subprocess")

needle = 'print("✓ chaos escalated")'
replacement = '''subprocess.run([str(ROOT / "Wonderland-v4" / "ephemeral" / "bin" / "wl-visual-chaos"), "launch-all"], check=False)
        print("✓ chaos escalated")
        print("✓ real visual apps triggered")'''

s = s.replace(needle, replacement)
p.write_text(s)
PY

  chmod +x "$MANAGER"
fi

echo "PASS visual chaos auto drop-in installed"
echo ""
echo "Verify:"
echo "  wl-visual-chaos status"
echo "  wl-ephemeral launch chaos-escalator --chaos"
