#!/usr/bin/env bash

set -euo pipefail

ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)}"
export PYTHONPATH="$ROOT/builder/python/wlplatform/src${PYTHONPATH:+:$PYTHONPATH}"

python3 -m unittest discover \
  -s "$ROOT/builder/python/wlplatform/tests" \
  -p 'test_mesh_relationship.py' \
  -v

python3 - <<'PY'
import json
from pathlib import Path

root = Path(__import__('os').environ['WL_ROOT']) if 'WL_ROOT' in __import__('os').environ else Path.cwd()
schema = root / 'schema/mesh.relationship.v1.json'
data = json.loads(schema.read_text())
assert data['$id'] == 'wonderland://schema/mesh.relationship.v1'
assert data['properties']['protocol']['const'] == 'mesh.relationship/1.0'
assert set(data['properties']['state']['enum']) == {
    'pending', 'active', 'suspended', 'revoked', 'expired', 'rejected'
}
print('SCHEMA PASS')
PY

printf '%s\n' "MESH RELATIONSHIP V1 VERIFY PASS"
