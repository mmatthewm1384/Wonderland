#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

CERT="$WL_ROOT/vault/08-Operations/certifications/runtime/wonderland-rootless.json"

test -f "$CERT"

python3 - "$CERT" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    data=json.load(f)

assert data["certified"] is True
assert data["instance"] == "wonderland-rootless"

print("CERTIFIED")
PY
