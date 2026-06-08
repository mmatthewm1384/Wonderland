#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo
echo "Wonderland Archive Verification"
echo "root: $ROOT"
echo

python3 - "$ROOT" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
failures = []

registry = root / "archive-registry.json"
policy = root / "archive-policy.md"

try:
    data = json.loads(registry.read_text())
except Exception as exc:
    failures.append(f"invalid archive-registry.json: {exc}")
else:
    if data.get("id") != "archive-registry-v4":
        failures.append("archive-registry id mismatch")
    if not isinstance(data.get("archives"), list):
        failures.append("archive-registry archives must be a list")

if not policy.exists():
    failures.append("MISSING archive-policy.md")
else:
    text = policy.read_text(errors="replace")
    if "<!-- id: archive-policy-v4 -->" not in text:
        failures.append("archive-policy id mismatch")

for d in ("retired", "superseded", "quarantine"):
    if not (root / d).is_dir():
        failures.append(f"MISSING directory {d}")

if failures:
    for failure in failures:
        print(f"FAIL    {failure}")
    print()
    print("RESULT  FAIL")
    sys.exit(1)

print("RESULT  PASS")
PY
