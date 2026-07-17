#!/usr/bin/env bash
set -euo pipefail

echo "== Certify Engine Registry v1.1 =="

ROOT="/Users/wonderland/Wonderland"

mkdir -p \
"$ROOT/vault/08-Operations/certifications/engines"


PYTHONPATH="$ROOT/builder/python/wlplatform" \
python3 <<'PY'

from pathlib import Path
from wlplatform.engines import get_engine


root = Path("/Users/wonderland/Wonderland")

engine = get_engine(
    "registry",
    root
)

result = engine.verify()

print(result.to_dict())

assert result.status == "PASS"

print("CERTIFICATION PASS")

PY
