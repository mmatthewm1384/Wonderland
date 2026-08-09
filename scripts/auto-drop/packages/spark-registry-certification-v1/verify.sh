#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"
fail(){ printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass(){ printf 'PASS: %s\n' "$*"; }
[ -f "$ROOT/sparks/registry.yaml" ] || fail "registry missing"
python3 - "$ROOT/sparks/registry.yaml" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text(encoding='utf-8')
required=(
 'schema: wonderland.spark-registry/v1',
 'policy: certification-gated',
 'discovery: declarative',
 'ui_ownership: spark',
 'certification_contract:',
 'required:',
 'identity',
 'manifest',
 'capabilities',
 'evidence',
 'ui',
 'certification',
 'discovery_requires: certification',
 'uncertified_visibility: hidden',
)
missing=[x for x in required if x not in s]
if missing:
    raise SystemExit('missing registry contract: '+', '.join(missing))
PY
pass "registry schema and certification contract"
[ -f "$ROOT/.wonderland/spark-registry-certification-v1.installed" ] || fail "installation marker missing"
pass "installation marker"
pass "Spark Registry Certification v1 verification complete"
