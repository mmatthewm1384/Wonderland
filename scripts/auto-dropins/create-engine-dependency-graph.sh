#!/usr/bin/env bash

set -euo pipefail

echo "== Wonderland Engine Dependency Graph Registry =="

ROOT="${ROOT:-$HOME/Wonderland}"

TARGET="$ROOT/vault/05-Registry/engines/dependency-graph.json"

mkdir -p "$(dirname "$TARGET")"

cat > "$TARGET" <<'JSON'
{
  "schema_version": 1,
  "engine_registry": "v1.5",
  "engines": [
    {
      "name": "architecture",
      "depends_on": []
    },
    {
      "name": "registry",
      "depends_on": [
        "architecture"
      ]
    },
    {
      "name": "governance",
      "depends_on": [
        "registry"
      ]
    },
    {
      "name": "builder",
      "depends_on": [
        "architecture",
        "registry"
      ]
    },
    {
      "name": "mirror",
      "depends_on": [
        "registry",
        "governance"
      ]
    },
    {
      "name": "academy",
      "depends_on": [
        "registry",
        "governance"
      ]
    },
    {
      "name": "runtime",
      "depends_on": [
        "architecture",
        "registry",
        "governance"
      ]
    }
  ]
}
JSON

echo "Created:"
echo "$TARGET"

python3 - <<PY
import json
from pathlib import Path

p = Path("$TARGET")

data=json.loads(
    p.read_text()
)

print(
    "PASS dependency graph",
    len(data["engines"]),
    "engines"
)
PY
