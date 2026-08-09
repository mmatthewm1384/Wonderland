#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }

[ -d "$ROOT/.git" ] || fail "not a Wonderland git repository"

for file in \
  Crystal/us/workspace.yaml \
  sparks/spark-matthew-001/manifest.yaml \
  sparks/spark-taylor-001/manifest.yaml \
  sparks/registry.yaml; do
  [ -f "$ROOT/$file" ] || fail "missing required file: $file"
done
pass "base mesh contracts exist"

for dir in \
  Crystal/us/identity \
  Crystal/us/trust \
  Crystal/us/registry \
  Crystal/us/evidence \
  Crystal/us/certification \
  sparks/spark-matthew-001/capabilities \
  sparks/spark-matthew-001/ui \
  sparks/spark-matthew-001/evidence \
  sparks/spark-taylor-001/capabilities \
  sparks/spark-taylor-001/ui \
  sparks/spark-taylor-001/evidence; do
  [ -d "$ROOT/$dir" ] || fail "missing mesh directory: $dir"
done
pass "Crystal Mesh and Spark Mesh paths exist"

python3 - "$ROOT/sparks/registry.yaml" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
required = (
    "schema: wonderland.spark-registry/v1",
    "policy: certification-gated",
    "discovery: declarative",
    "ui_ownership: spark",
)
missing = [item for item in required if item not in text]
if missing:
    print("missing registry invariants:", ", ".join(missing), file=sys.stderr)
    raise SystemExit(1)
PY
pass "registry invariants are present"

if [ -e "$ROOT/.wonderland/spark-mesh-foundation-v1.installed" ]; then
  pass "installation marker present"
else
  pass "installation marker absent (pre-install verification)"
fi

pass "Spark Mesh Foundation v1 verification complete"
