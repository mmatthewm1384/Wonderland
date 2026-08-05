#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

LEDGER="$WL_ROOT/vault/08-Operations/certifications/runtime/ledger.jsonl"

test -f "$LEDGER"

python3 - "$LEDGER" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    entries=[json.loads(line) for line in f if line.strip()]

assert entries

latest = entries[-1]

assert latest["target"] == "wonderland-rootless"
assert latest["certified"] is True

print("CERTIFIED")
PY
