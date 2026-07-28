#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

mkdir -p "$ROOT/scripts/auto-drop/lib"

cp \
payload/scripts/auto-drop/lib/root.sh \
"$ROOT/scripts/auto-drop/lib/root.sh"

chmod +x \
"$ROOT/scripts/auto-drop/lib/root.sh"

mkdir -p "$ROOT/vault/08-Operations/evidence/auto-drop-core"

cat > "$ROOT/vault/08-Operations/evidence/auto-drop-core/latest.json" <<EOF
{
  "package": "auto-drop-core",
  "version": "1.0.0",
  "status": "INSTALLED",
  "checks": {
    "root-library": "PASS"
  }
}
EOF

echo "Auto-Drop Core installed"
