#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "$ROOT" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])

registry = json.loads(
    (root / "runbook-registry.json").read_text()
)

failures = []

for rb in registry["runbooks"]:
    p = root / rb["path"]

    if not p.exists():
        failures.append(f"MISSING {rb['path']}")
        continue

    text = p.read_text()

    expected = f"<!-- id: {rb['id']} -->"

    if expected not in text:
        failures.append(
            f"id mismatch: {rb['path']}"
        )

    print(f"OK {rb['path']}")

if failures:
    print()
    for f in failures:
        print("FAIL", f)
    sys.exit(1)

print()
print("RESULT PASS")
PY
