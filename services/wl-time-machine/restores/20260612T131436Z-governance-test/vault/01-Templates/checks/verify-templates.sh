#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REGISTRY="$ROOT/template-registry.json"

echo
echo "Wonderland Template Verification"
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

templates = registry.get("templates")
if not isinstance(templates, list):
    print("FAIL templates must be a list")
    sys.exit(1)

seen_ids = set()
seen_paths = set()

for template in templates:
    for field in ("id", "path", "type"):
        if field not in template:
            failures.append(f"missing field {field}: {template}")

    template_id = template.get("id")
    rel_path = template.get("path")

    if not template_id or not rel_path:
        continue

    if template_id in seen_ids:
        failures.append(f"duplicate template id: {template_id}")
    seen_ids.add(template_id)

    if rel_path in seen_paths:
        failures.append(f"duplicate template path: {rel_path}")
    seen_paths.add(rel_path)

    target = root / rel_path
    if not target.exists():
        failures.append(f"MISSING {rel_path}")
        continue

    print(f"OK      {rel_path}")

    if target.suffix == ".json":
        try:
            json.loads(target.read_text())
        except Exception as exc:
            failures.append(f"invalid json {rel_path}: {exc}")

    if target.suffix == ".md":
        text = target.read_text(errors="replace")
        if "{{" not in text or "}}" not in text:
            failures.append(f"template placeholders missing: {rel_path}")

print()

if failures:
    for failure in failures:
        print(f"FAIL    {failure}")
    print()
    print("RESULT  FAIL")
    sys.exit(1)

print("RESULT  PASS")
PY
