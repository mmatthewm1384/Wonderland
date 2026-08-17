#!/usr/bin/env bash

set -euo pipefail

ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)}"
BACKUP="$ROOT/builder/python/wlplatform/migration/backups/mesh-relationship-v1"

mkdir -p "$BACKUP"

for path in \
  "$ROOT/builder/python/wlplatform/src/wlplatform/mesh/__init__.py" \
  "$ROOT/builder/python/wlplatform/src/wlplatform/mesh/relationship.py" \
  "$ROOT/schema/mesh.relationship.v1.json" \
  "$ROOT/builder/python/wlplatform/tests/test_mesh_relationship.py"; do
  if [[ -e "$path" ]]; then
    relative="${path#"$ROOT/"}"
    destination="$BACKUP/$relative"
    mkdir -p "$(dirname "$destination")"
    mv "$path" "$destination"
  fi
done

rmdir "$ROOT/builder/python/wlplatform/src/wlplatform/mesh" 2>/dev/null || true

printf '%s\n' "MESH RELATIONSHIP V1 ROLLBACK PASS"
