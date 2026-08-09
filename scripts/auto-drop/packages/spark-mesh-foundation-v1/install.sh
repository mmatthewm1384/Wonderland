#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"

PACKAGE_DIR="$(cd "$(dirname "$0")" && pwd)"
MARKER="$ROOT/.wonderland/spark-mesh-foundation-v1.installed"

say() { printf '%s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

say "== Spark Mesh Foundation v1 =="
say "root: $ROOT"

[ -d "$ROOT/.git" ] || fail "not a Wonderland git repository"
[ -f "$PACKAGE_DIR/manifest.yaml" ] || fail "package manifest missing"

say
say "== Preflight =="
for required in \
  Crystal/us/workspace.yaml \
  sparks/spark-matthew-001/manifest.yaml \
  sparks/spark-taylor-001/manifest.yaml; do
  [ -e "$ROOT/$required" ] || fail "required existing contract missing: $required"
  say "PASS $required"
done

say
say "== Creating non-destructive mesh paths =="
paths=(
  Crystal/us/identity
  Crystal/us/trust
  Crystal/us/registry
  Crystal/us/evidence
  Crystal/us/certification
  sparks/spark-matthew-001/capabilities
  sparks/spark-matthew-001/ui
  sparks/spark-matthew-001/evidence
  sparks/spark-taylor-001/capabilities
  sparks/spark-taylor-001/ui
  sparks/spark-taylor-001/evidence
)

for path in "${paths[@]}"; do
  mkdir -p "$ROOT/$path"
  say "READY $path"
done

if [ ! -e "$ROOT/sparks/registry.yaml" ]; then
  cat > "$ROOT/sparks/registry.yaml" <<'YAML'
schema: wonderland.spark-registry/v1
version: 1
registry:
  policy: certification-gated
  discovery: declarative
  ui_ownership: spark
sparks: []
YAML
  say "CREATED sparks/registry.yaml"
else
  say "PRESERVED sparks/registry.yaml"
fi

mkdir -p "$(dirname "$MARKER")"
printf 'package: spark-mesh-foundation-v1\nversion: 1.0.0\ninstalled_at: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" > "$MARKER"

say
say "== Verification =="
bash "$PACKAGE_DIR/verify.sh"

say
say "PASS: Spark Mesh Foundation v1 installed"
