#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

python3 <<PY
import json

path="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/registry.json"

data=json.load(open(path))

assert "certification" in data["runtimes"]["wonderland-rootless"]

print("REGISTRY VALID")
PY

echo "CERTIFIED"

