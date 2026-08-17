#!/usr/bin/env bash

set -euo pipefail

ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)}"
BACKUP="$ROOT/builder/python/wlplatform/migration/backups/mesh-relationship-v1"

mkdir -p "$BACKUP"

for path in \
  "$ROOT/builder/python/wlplatform/src/wlplatform/mesh" \
  "$ROOT/schema/mesh.relationship.v1.json" \
  "$ROOT/builder/python/wlplatform/tests/test_mesh_relationship.py"; do
  if [[ -e "$path" ]]; then
    case "$path" in
      */mesh)
        mv "$path" "$BACKUP/mesh"
        ;;
      */mesh.relationship.v1.json)
        mv "$path" "$BACKUP/mesh.relationship.v1.json"
        ;;
      */test_mesh_relationship.py)
        mv "$path" "$BACKUP/test_mesh_relationship.py"
        ;;
    esac
  fi
done

printf '%s\n' "MESH RELATIONSHIP V1 ROLLBACK PASS"
