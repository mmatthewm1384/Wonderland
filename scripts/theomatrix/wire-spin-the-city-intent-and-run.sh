#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
APP="$WL_HOME/apps/tauri/wl-spin-city"
REG="$WL_ROOT/intents/theomatrix-intent-registry.json"
INTENT="$WL_ROOT/intents/spin-the-city-eye-time-space.intent.json"

echo "== wire spin-the-city intent =="

test -f "$INTENT" || { echo "FAIL missing intent: $INTENT"; exit 1; }
test -d "$APP" || { echo "FAIL missing app: $APP"; exit 1; }

mkdir -p "$(dirname "$REG")"

python3 - <<PY
import json, pathlib, datetime

reg = pathlib.Path("$REG")
intent = pathlib.Path("$INTENT")

entry = {
  "intent_id": "theomatrix.spin-the-city.eye-time-space.v1",
  "title": "Spin-The-City Eye-Time-Space Intent",
  "path": str(intent),
  "app": "spin-the-city",
  "source_app_path": "$APP",
  "status": "active",
  "registered_at": datetime.datetime.now().isoformat(timespec="seconds")
}

if reg.exists():
    data = json.loads(reg.read_text())
else:
    data = {"registry": "theomatrix.intent.registry.v1", "intents": []}

data["intents"] = [
    x for x in data.get("intents", [])
    if x.get("intent_id") != entry["intent_id"]
]
data["intents"].append(entry)

reg.write_text(json.dumps(data, indent=2) + "\n")
print("PASS registry")
print(reg)
PY

echo
echo "== verify =="
wl-spin-the-city-intent verify
python3 -m json.tool "$REG" >/dev/null
grep -q "theomatrix.spin-the-city.eye-time-space.v1" "$REG"
echo "PASS registry-contains-intent"

echo
echo "== run app =="
cd "$APP"

if [[ -f package.json ]]; then
  if command -v pnpm >/dev/null 2>&1; then
    pnpm install
    pnpm tauri dev
  elif command -v npm >/dev/null 2>&1; then
    npm install
    npm run tauri dev
  else
    echo "FAIL missing npm/pnpm"
    exit 1
  fi
elif [[ -f src-tauri/Cargo.toml ]]; then
  cd src-tauri
  cargo run
else
  echo "FAIL unknown Tauri app layout"
  exit 1
fi

