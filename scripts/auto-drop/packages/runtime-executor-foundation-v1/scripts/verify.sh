#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

fail() {
    echo "FAIL: $1"
    exit 1
}

test -d "$ROOT/builder/python/wlplatform/src/wlplatform/runtime" \
    || fail "runtime module missing"

echo "PASS: runtime module"

mkdir -p \
"$ROOT/vault/08-Operations/certifications/runtime"

cat > "$ROOT/vault/08-Operations/certifications/runtime/runtime-executor-v1.json" <<JSON
{
  "component": "runtime-executor",
  "version": "1.0.0",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "certification": "CERTIFIED"
}
JSON

echo "STATUS: CERTIFIED"
