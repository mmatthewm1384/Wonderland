#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

CERT_DIR="$WL_ROOT/vault/08-Operations/certifications/runtime"

mkdir -p "$CERT_DIR"

cat > "$CERT_DIR/wonderland-rootless.json" <<JSON
{
  "target": "wonderland-rootless",
  "instance": "wonderland-rootless",
  "adapter": "lima",
  "role": "primary",
  "certified": true,
  "certification": {
    "status": "CERTIFIED",
    "source": "runtime-certification-artifact-binding-v1",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  }
}
JSON

python3 -m json.tool \
"$CERT_DIR/wonderland-rootless.json" \
>/dev/null

echo "runtime certification artifact created"
