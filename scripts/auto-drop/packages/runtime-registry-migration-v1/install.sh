#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

REGISTRY_DIR="$WL_ROOT/runtime/registry"
EVIDENCE_DIR="$WL_ROOT/vault/08-Operations/evidence/runtime"

mkdir -p "$REGISTRY_DIR"
mkdir -p "$EVIDENCE_DIR"

cp \
"$(dirname "$0")/artifacts/runtime-registry-v1.yaml" \
"$REGISTRY_DIR/runtime-registry-v1.yaml"

cat > "$EVIDENCE_DIR/runtime-migration-v1.json" <<EOF
{
  "service": "runtime",
  "action": "migration",
  "version": "1.0",
  "from": "wonderland-rootless",
  "to": "wonderland-debian-rootless-v1",
  "status": "prepared"
}
EOF

echo "runtime-registry-migration-v1 installed"
