#!/usr/bin/env bash

set -euo pipefail

ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)}"

SOURCE="$ROOT/builder/python/wlplatform/src/wlplatform/mesh/relationship.py"
INIT="$ROOT/builder/python/wlplatform/src/wlplatform/mesh/__init__.py"
SCHEMA="$ROOT/schema/mesh.relationship.v1.json"
TEST="$ROOT/builder/python/wlplatform/tests/test_mesh_relationship.py"

for path in "$SOURCE" "$INIT" "$SCHEMA" "$TEST"; do
  [[ -f "$path" ]] || { echo "MISSING: $path" >&2; exit 1; }
done

printf '%s\n' "mesh-relationship-v1 source present"
printf '%s\n' "No network transport or external dependency installation performed"
