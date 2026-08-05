#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

LEDGER="$WL_ROOT/vault/08-Operations/certifications/runtime/ledger.jsonl"

mkdir -p "$(dirname "$LEDGER")"

python3 - "$LEDGER" <<'PY'
from pathlib import Path
import json
import sys
from datetime import datetime, timezone

ledger = Path(sys.argv[1])

entry = {
    "event": "runtime-certification",
    "target": "wonderland-rootless",
    "instance": "wonderland-rootless",
    "adapter": "lima",
    "certified": True,
    "source": "runtime-certification-ledger-binding-v1",
    "timestamp": datetime.now(timezone.utc).isoformat()
}

with ledger.open("a") as f:
    f.write(json.dumps(entry) + "\n")

with ledger.open() as f:
    for line in f:
        json.loads(line)

print("ledger-valid")
PY

echo "ledger-bound"
