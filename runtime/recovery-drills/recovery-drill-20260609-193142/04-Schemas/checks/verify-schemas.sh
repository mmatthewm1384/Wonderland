#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REGISTRY="$ROOT/schema-registry.json"

echo
echo "Wonderland Schema Verification"
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

schemas = registry.get("schemas")
if not isinstance(schemas, list):
    print("FAIL schemas must be a list")
    sys.exit(1)

seen_ids = set()
seen_paths = set()

for schema in schemas:
    for field in ("id", "path", "type"):
        if field not in schema:
            failures.append(f"missing field {field}: {schema}")

    schema_id = schema.get("id")
    rel_path = schema.get("path")

    if not schema_id or not rel_path:
        continue

    if schema_id in seen_ids:
        failures.append(f"duplicate schema id: {schema_id}")
    seen_ids.add(schema_id)

    if rel_path in seen_paths:
        failures.append(f"duplicate schema path: {rel_path}")
    seen_paths.add(rel_path)

    target = root / rel_path
    if not target.exists():
        failures.append(f"MISSING {rel_path}")
        continue

    print(f"OK      {rel_path}")

    try:
        data = json.loads(target.read_text())
    except Exception as exc:
        failures.append(f"invalid json {rel_path}: {exc}")
        continue

    if data.get("$id") != schema_id:
        failures.append(
            f"id mismatch in {rel_path}; expected {schema_id} found {data.get('$id')}"
        )

    if data.get("type") != "object":
        failures.append(f"schema is not object type: {rel_path}")

print()

if failures:
    for failure in failures:
        print(f"FAIL    {failure}")
    print()
    print("RESULT  FAIL")
    sys.exit(1)

print("RESULT  PASS")
PY
