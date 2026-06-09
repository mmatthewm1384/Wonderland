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
import re
import sys

root = pathlib.Path(sys.argv[1])
wonderland = pathlib.Path(sys.argv[2])
registry_path = pathlib.Path(sys.argv[3])

required = {
    "id",
    "name",
    "status",
    "version",
    "compose",
    "verify",
    "recover",
    "rollback",
    "dependencies",
    "ports",
    "volumes"
}

name_re = re.compile(r"^wl-[a-z0-9-]+$")

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

        if not name_re.match(name):
            failures.append(f"invalid service name: {name}")

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

        missing = sorted(required - set(data.keys()))
        if missing:
            failures.append(f"missing fields in {path}: {missing}")

        if data.get("name") != name:
            failures.append(f"name mismatch in {path}")

        if data.get("id") != f"{name}-service-v4":
            failures.append(f"id mismatch in {path}")

        if data.get("version") != 4:
            failures.append(f"version mismatch in {path}")

        if data.get("status") not in {"draft", "active", "locked", "deprecated", "archived"}:
            failures.append(f"invalid status in {path}: {data.get('status')}")

        if compose and not (wonderland / compose).exists():
            failures.append(f"MISSING compose for {name}: {compose}")

        if not isinstance(data.get("dependencies"), list):
            failures.append(f"dependencies must be list in {path}")

        if not isinstance(data.get("ports"), list):
            failures.append(f"ports must be list in {path}")

        if not isinstance(data.get("volumes"), list):
            failures.append(f"volumes must be list in {path}")

print()

if failures:
    for failure in failures:
        print(f"FAIL    {failure}")
    print()
    print("RESULT  FAIL")
    sys.exit(1)

print("RESULT  PASS")
PY
