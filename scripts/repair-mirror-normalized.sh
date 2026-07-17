#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SRC="$ROOT/vault/08-Operations/certifications/engines/mirror-certification.json"
OUT="$ROOT/vault/08-Operations/certifications/normalized/mirror.json"

if [[ ! -f "$SRC" ]]; then
    echo "missing source:"
    echo "$SRC"
    exit 1
fi

python3 - "$SRC" "$OUT" <<'PY'
from pathlib import Path
import json
import hashlib
import sys

src = Path(sys.argv[1])
out = Path(sys.argv[2])

data = json.loads(src.read_text())

payload = {
    "schema_version": 1,
    "engine": "mirror",
    "status": data.get("status", "UNKNOWN"),
    "certified": data.get("certified", False),
    "source": str(src),
    "digest": hashlib.sha256(
        src.read_bytes()
    ).hexdigest(),
}

out.write_text(
    json.dumps(
        payload,
        indent=2
    ) + "\n"
)

print(json.dumps(payload, indent=2))
PY

echo "updated:"
echo "$OUT"
