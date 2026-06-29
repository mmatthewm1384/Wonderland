#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
EPH="$ROOT/Wonderland-v4/ephemeral"
BIN="$EPH/bin"
VAULT="$ROOT/vault"
CHAOS="$VAULT/chaos"
RUNTIME="$VAULT/runtime"
CONTRACT="$CHAOS/visual-chaos-contract.json"

mkdir -p "$BIN" "$CHAOS" "$RUNTIME"

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
now = datetime.now(timezone.utc).isoformat()

active = aether.exists()
payload = {
  "version": "1.0",
  "updated_at": now,
  "chaos_active": active,
  "source": str(aether),
  "apps": {
    "wl-spin-city": {
      "enabled": True,
      "rings": 5 if active else 3,
      "rotation_speed": 2.0 if active else 1.0,
      "easing": "extreme" if active else "normal",
      "jitter": 2.0 if active else 0.35,
      "palette": ["#05070A", "#00E5FF", "#7000FF", "#00FF66", "#FF00AA"]
    },
    "wl-agitate": {
      "enabled": True,
      "intensity": 2.0 if active else 0.6,
      "mode": "hybrid-max-jitter" if active else "normal",
      "trail_decay": "slow" if active else "normal",
      "palette": ["#05070A", "#00E5FF", "#7000FF", "#00FF66", "#FF00AA"]
    },
    "wl-matrix": {
      "enabled": True,
      "particles": 10000 if active else 1200,
      "living_ratio": 0.9 if active else 0.35,
      "waste_decay": "slow" if active else "normal",
      "slam_force": 2.0 if active else 0.7,
      "palette": ["#05070A", "#00E5FF", "#7000FF", "#00FF66", "#FF00AA"]
    }
  }
}

contract.write_text(json.dumps(payload, indent=2, sort_keys=True))
print(contract)
PY
}

case "${1:-status}" in
  write-contract)
    write_contract
    ;;
  status)
    write_contract >/dev/null
    cat "$CONTRACT"
    ;;
  launch-spin-city)
    write_contract >/dev/null
    export WL_CHAOS_CONTRACT="$CONTRACT"
    export WL_CHAOS_ACTIVE="$(python3 -c "import json;print(str(json.load(open('$CONTRACT'))['chaos_active']).lower())")"
    open -a "$ROOT/apps/macos/Spin City Wave.app" || true
    ;;
  launch-agitate)
    write_contract >/dev/null
    export WL_CHAOS_CONTRACT="$CONTRACT"
    export WL_CHAOS_ACTIVE="$(python3 -c "import json;print(str(json.load(open('$CONTRACT'))['chaos_active']).lower())")"
    open -a "$ROOT/apps/macos/Agitate Waves.app" || true
    ;;
  launch-matrix)
    write_contract >/dev/null
    export WL_CHAOS_CONTRACT="$CONTRACT"
    export WL_CHAOS_ACTIVE="$(python3 -c "import json;print(str(json.load(open('$CONTRACT'))['chaos_active']).lower())")"
    open -a "$ROOT/apps/macos/Matrix Atom Destroyer.app" || true
    ;;
  launch-all)
    "$0" launch-spin-city
    "$0" launch-agitate
    "$0" launch-matrix
    ;;
  *)
    echo "Usage: wl-visual-chaos write-contract|status|launch-spin-city|launch-agitate|launch-matrix|launch-all"
    exit 2
    ;;
esac
SH

chmod +x "$BIN/wl-visual-chaos"

echo "Installed wl-visual-chaos bridge."
echo "Contract: $CONTRACT"
