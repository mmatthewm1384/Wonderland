#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

REGISTRY="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/registry.json"

cp "$REGISTRY" "$REGISTRY.runtime-primary-certification-registration-v1.bak"


python3 <<PY
import json
from pathlib import Path

path = Path("$REGISTRY")

data = json.loads(path.read_text())

runtime = data["runtimes"]["wonderland-rootless"]

runtime["certification"] = {
    "required": True,
    "package": "runtime-primary-certification-v1"
}

path.write_text(
    json.dumps(data, indent=2) + "\n"
)

PY

echo "Primary runtime certification registered"

