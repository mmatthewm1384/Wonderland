#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REGISTRY="$ROOT/policy-registry.json"

echo
echo "Wonderland Policy Verification"
echo "root: $ROOT"
echo

python3 - "$ROOT" "$REGISTRY" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
registry_path = pathlib.Path(sys.argv[2])

failures = []

try:
    registry = json.loads(registry_path.read_text())
except Exception as exc:
    print(f"FAIL registry parse: {registry_path}: {exc}")
    sys.exit(1)

policies = registry.get("policies")
if not isinstance(policies, list):
    print("FAIL policies must be a list")
    sys.exit(1)

seen = set()

for policy in policies:
    for field in ("id", "path", "type"):
        if field not in policy:
            failures.append(f"missing field {field}: {policy}")

    policy_id = policy.get("id")
    rel_path = policy.get("path")

    if not rel_path:
        continue

    if rel_path in seen:
        failures.append(f"duplicate policy path: {rel_path}")
    seen.add(rel_path)

    target = root / rel_path
    if not target.exists():
        failures.append(f"MISSING {rel_path}")
        continue

    print(f"OK      {rel_path}")

    text = target.read_text(errors="replace")
    expected = f"<!-- id: {policy_id} -->"
    if expected not in text:
        failures.append(f"id mismatch in {rel_path}; expected {expected}")

print()

if failures:
    for failure in failures:
        print(f"FAIL    {failure}")
    print()
    print("RESULT  FAIL")
    sys.exit(1)

print("RESULT  PASS")
PY
