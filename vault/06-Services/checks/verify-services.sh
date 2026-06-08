#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WONDERLAND="/Users/wonderland/Wonderland"
REGISTRY="$ROOT/service-registry.json"

echo
echo "Wonderland Service Definition Verification"
echo "root: $ROOT"
echo

python3 - "$ROOT" "$WONDERLAND" "$REGISTRY" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
wonderland = pathlib.Path(sys.argv[2])
registry_path = pathlib.Path(sys.argv[3])

failures = []

try:
    registry = json.loads(registry_path.read_text())
except Exception as exc:
    print(f"FAIL registry parse: {exc}")
    sys.exit(1)

if registry.get("id") != "service-registry-v4":
    failures.append("service-registry id mismatch")

services = registry.get("services")
if not isinstance(services, list):
    failures.append("services must be a list")
else:
    seen = set()

    for svc in services:
        name = svc.get("name")
        path = svc.get("path")
        compose = svc.get("compose")

        if not name or not path:
            failures.append(f"invalid service entry: {svc}")
            continue

        if name in seen:
            failures.append(f"duplicate service name: {name}")
        seen.add(name)

        definition = root / path
        if not definition.exists():
            failures.append(f"MISSING definition {path}")
            continue

        print(f"OK      {path}")

        try:
            data = json.loads(definition.read_text())
        except Exception as exc:
            failures.append(f"invalid json {path}: {exc}")
            continue

        if data.get("name") != name:
            failures.append(f"name mismatch in {path}")

        if compose and not (wonderland / compose).exists():
            failures.append(f"MISSING compose for {name}: {compose}")

print()

if failures:
    for failure in failures:
        print(f"FAIL    {failure}")
    print()
    print("RESULT  FAIL")
    sys.exit(1)

print("RESULT  PASS")
PY
