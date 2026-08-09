#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"
PACKAGE_DIR="$(cd "$(dirname "$0")" && pwd)"
FOUNDATION_VERIFY="$ROOT/scripts/auto-drop/packages/spark-mesh-foundation-v1/verify.sh"
REGISTRY="$ROOT/sparks/registry.yaml"
BACKUP="$ROOT/.wonderland/registry-certification-v1.preinstall.yaml"
MARKER="$ROOT/.wonderland/spark-registry-certification-v1.installed"
fail(){ printf 'ERROR: %s\n' "$*" >&2; exit 1; }
pass(){ printf 'PASS: %s\n' "$*"; }

[ -d "$ROOT/.git" ] || fail "not a Wonderland git repository"
[ -f "$FOUNDATION_VERIFY" ] || fail "Spark Mesh Foundation package is missing"

printf '%s\n' '== Spark Mesh Foundation dependency ==' 
bash "$FOUNDATION_VERIFY" >/dev/null || fail "Spark Mesh Foundation verification failed; install or repair the foundation first"
pass "Spark Mesh Foundation verified"

[ -f "$REGISTRY" ] || fail "Spark Mesh Foundation registry contract is missing"
mkdir -p "$ROOT/.wonderland"
if [ ! -e "$BACKUP" ]; then cp "$REGISTRY" "$BACKUP"; fi
python3 - "$REGISTRY" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
s=p.read_text(encoding='utf-8')
required=(
 'schema: wonderland.spark-registry/v1',
 'version: 1',
 'policy: certification-gated',
 'discovery: declarative',
 'ui_ownership: spark',
 'sparks:',
)
missing=[x for x in required if x not in s]
if missing:
    raise SystemExit('registry contract missing: '+', '.join(missing))
block='''# Certification contract: every discovered Spark must provide identity,\n# manifest, capabilities, evidence, UI metadata, and a valid certification record.\ncertification_contract:\n  required:\n    - identity\n    - manifest\n    - capabilities\n    - evidence\n    - ui\n    - certification\n  discovery_requires: certification\n  uncertified_visibility: hidden\n'''
if 'certification_contract:' not in s:
    p.write_text(s.rstrip()+'\n\n'+block, encoding='utf-8')
PY
printf 'package: spark-registry-certification-v1\nversion: 1.0.0\ninstalled_at: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" > "$MARKER"
printf '%s\n' '== Spark Registry Certification v1 ==' '== Verification =='
bash "$PACKAGE_DIR/verify.sh"
printf '%s\n' 'PASS: Spark Registry Certification v1 installed'
