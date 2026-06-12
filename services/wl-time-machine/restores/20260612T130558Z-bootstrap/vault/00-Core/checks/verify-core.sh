#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REGISTRY="$ROOT/manifests/document-registry.json"

echo
echo "Wonderland Core Verification"
echo "root: $ROOT"
echo

python3 - "$ROOT" "$REGISTRY" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
registry_path = pathlib.Path(sys.argv[2])

required_fields = {"id", "path", "layer", "status", "version"}
allowed_status = {"draft", "active", "locked", "deprecated"}

failures = []

try:
    registry = json.loads(registry_path.read_text())
except Exception as exc:
    print(f"FAIL registry parse: {registry_path}: {exc}")
    sys.exit(1)

docs = registry.get("documents")
if not isinstance(docs, list):
    print("FAIL registry documents must be a list")
    sys.exit(1)

seen_ids = set()
seen_paths = set()

for doc in docs:
    missing = required_fields - set(doc.keys())
    if missing:
        failures.append(f"registry record missing fields {sorted(missing)}: {doc}")
        continue

    doc_id = doc["id"]
    rel_path = doc["path"]
    status = doc["status"]

    if doc_id in seen_ids:
        failures.append(f"duplicate id: {doc_id}")
    seen_ids.add(doc_id)

    if rel_path in seen_paths:
        failures.append(f"duplicate path: {rel_path}")
    seen_paths.add(rel_path)

    if status not in allowed_status:
        failures.append(f"invalid status for {rel_path}: {status}")

    target = root / rel_path
    if not target.exists():
        failures.append(f"MISSING {rel_path}")
        continue

    print(f"OK      {rel_path}")

    if target.suffix == ".md":
        text = target.read_text(errors="replace")
        expected = f"<!-- id: {doc_id} -->"
        if expected not in text:
            failures.append(
                f"id mismatch in {rel_path}; expected marker: {expected}"
            )

    elif target.suffix == ".json":
        try:
            data = json.loads(target.read_text())

            if rel_path.endswith("vault-state.json"):
                manifest_id = data.get("id")
                if manifest_id != doc_id:
                    failures.append(
                        f"id mismatch in {rel_path}; expected '{doc_id}' found '{manifest_id}'"
                    )

            elif rel_path.endswith("document-registry.json"):
                if "documents" not in data:
                    failures.append(f"registry missing documents array: {rel_path}")

            elif rel_path.endswith("layers.json"):
                if "layers" not in data:
                    failures.append(f"layers missing layers array: {rel_path}")

            elif rel_path.endswith("protected-paths.json"):
                if "protected" not in data:
                    failures.append(f"protected-paths missing protected array: {rel_path}")

            elif rel_path.endswith("promotions.json"):
                if "requirements" not in data:
                    failures.append(f"promotions missing requirements array: {rel_path}")

        except Exception as exc:
            failures.append(f"invalid json {rel_path}: {exc}")

print()

if failures:
    for failure in failures:
        print(f"FAIL    {failure}")
    print()
    print("RESULT  FAIL")
    sys.exit(1)

print("RESULT  PASS")
PY
