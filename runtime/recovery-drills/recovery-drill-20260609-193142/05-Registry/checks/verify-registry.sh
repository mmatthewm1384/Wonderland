#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAP="$ROOT/registry-map.json"

echo
echo "Wonderland Registry Verification"
echo "root: $ROOT"
echo

python3 - "$ROOT" "$MAP" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
map_path = pathlib.Path(sys.argv[2])
failures = []

data = json.loads(map_path.read_text())

if data.get("id") != "registry-map-v4":
    failures.append("registry-map id mismatch")

for reg in data.get("registries", []):
    reg_id = reg.get("id")
    rel_path = reg.get("path")
    reg_type = reg.get("type")

    target = root / rel_path

    if not target.exists():
        failures.append(f"MISSING {rel_path}")
        continue

    print(f"OK      {rel_path}")

    payload = json.loads(target.read_text())

    if payload.get("id") != reg_id:
        failures.append(
            f"id mismatch in {rel_path}; expected {reg_id} found {payload.get('id')}"
        )

    if reg_type not in payload:
        failures.append(f"missing collection '{reg_type}' in {rel_path}")

print()

if failures:
    for failure in failures:
        print(f"FAIL    {failure}")
    print()
    print("RESULT  FAIL")
    sys.exit(1)

print("RESULT  PASS")
PY
