#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PYTHONPATH="$ROOT/builder/python/wlplatform" python3 - <<'PY'
from pathlib import Path
import json

from wlplatform.certification_state import CertificationState

state = CertificationState(Path(".")).collect()

print("\n=== CERTIFICATION STATE ===")
print(json.dumps(state, indent=2))

print("\n=== ENGINE SUMMARY ===")

for name, data in state.get("engines", {}).items():
    print(
        f"{name:15}",
        "status=",
        data.get("status"),
        "certified=",
        data.get("certified"),
    )

print("\n=== TRUST ===")
print(json.dumps(state.get("trust"), indent=2))
PY
