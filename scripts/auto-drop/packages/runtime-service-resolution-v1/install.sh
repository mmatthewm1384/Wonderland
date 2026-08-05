#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/runtime/service-resolution"

mkdir -p "$TARGET"

cat > "$TARGET/runtime-resolution-policy.yaml" <<EOF
version: "1.0"

resolution:
  source: runtime-registry-v1.yaml

targets:

  host:
    registry_key: active.host
    instance: wonderland-debian-rootless-v1

  legacy:
    instance: wonderland-rootless
    access: rollback-only
EOF

echo "runtime-service-resolution-v1 installed"
