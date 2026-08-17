#!/usr/bin/env bash

set -euo pipefail

ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)}"
export PYTHONPATH="$ROOT/builder/python/wlplatform/src${PYTHONPATH:+:$PYTHONPATH}"

for test_file in \
  test_mesh_relationship.py \
  test_relationship_store.py \
  test_crystal_projection.py; do
  python3 -m unittest discover \
    -s "$ROOT/builder/python/wlplatform/tests" \
    -p "$test_file" \
    -v
done

python3 - <<'PY'
import json
import os
from pathlib import Path

root = Path(os.environ['WL_ROOT']) if 'WL_ROOT' in os.environ else Path.cwd()

relationship_schema = json.loads((root / 'schema/mesh.relationship.v1.json').read_text())
assert relationship_schema['$id'] == 'wonderland://schema/mesh.relationship.v1'
assert relationship_schema['properties']['protocol']['const'] == 'mesh.relationship/1.0'
assert set(relationship_schema['properties']['state']['enum']) == {
    'pending', 'active', 'suspended', 'revoked', 'expired', 'rejected'
}

projection_schema = json.loads((root / 'schema/crystal.mesh.relationship.v1.json').read_text())
assert projection_schema['$id'] == 'wonderland://schema/crystal.mesh.relationship.v1'
assert projection_schema['properties']['protocol']['const'] == 'crystal.mesh.relationship/1.0'
assert projection_schema['properties']['object_type']['const'] == 'mesh.relationship'

store = root / 'builder/python/wlplatform/src/wlplatform/mesh/relationship_store.py'
projection = root / 'builder/python/wlplatform/src/wlplatform/mesh/crystal_projection.py'
assert store.exists()
assert projection.exists()

print('RELATIONSHIP SCHEMA PASS')
print('CRYSTAL PROJECTION SCHEMA PASS')
print('STORE SOURCE PASS')
print('PROJECTION SOURCE PASS')
PY

printf '%s\n' "MESH RELATIONSHIP V1 VERIFY PASS"
