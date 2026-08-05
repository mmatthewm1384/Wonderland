#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

CERT="$WL_ROOT/vault/08-Operations/certifications/runtime/wonderland-rootless-certification.json"


test -f "$CERT"


python3 - <<PY
import json

with open("$CERT") as f:
    data=json.load(f)

assert data["instance"] == "wonderland-rootless"
assert data["certified"] is True

print("CERTIFICATION VALID")
PY


echo "CERTIFIED"

