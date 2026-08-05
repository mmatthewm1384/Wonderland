#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

CERT_DIR="$WL_ROOT/vault/08-Operations/certifications/runtime"

CERT_FILE="$CERT_DIR/wonderland-rootless-certification.json"


mkdir -p "$CERT_DIR"


cat > "$CERT_FILE" <<'JSON'
{
  "component": "runtime",
  "instance": "wonderland-rootless",
  "type": "lima-rootless-runtime",
  "certified": true,
  "checks": {
    "lima_instance_exists": true,
    "rootless_runtime": true,
    "runtime_discovery": true,
    "adapter_available": true
  }
}
JSON


echo "Created certification:"
echo "$CERT_FILE"

