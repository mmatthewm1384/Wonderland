#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "== Wonderland Engine Registry v1.1 Schema =="

REG="$ROOT/vault/05-Registry/engines"

mkdir -p "$REG"

cat > "$REG/engine-index.json" <<'EOF'
{
  "schema_version": "1.1",
  "engines": {
    "architecture": {
      "owner": "wlarchitecture",
      "capabilities": [
        "architecture-validation",
        "layer-boundaries",
        "dependency-analysis"
      ]
    },
    "builder": {
      "owner": "wlbuilder",
      "capabilities": [
        "image-build",
        "stage-validation"
      ]
    },
    "governance": {
      "owner": "wlgovernance",
      "capabilities": [
        "policy-validation",
        "schema-validation"
      ]
    },
    "registry": {
      "owner": "wlplatform",
      "capabilities": [
        "engine-discovery",
        "command-registration",
        "capability-ownership"
      ]
    },
    "mirror": {
      "owner": "wlmirror",
      "capabilities": [
        "snapshot",
        "restore",
        "diff"
      ]
    },
    "academy": {
      "owner": "wlacademy",
      "capabilities": [
        "lesson-registry",
        "knowledge-validation"
      ]
    }
  }
}
EOF

echo "Schema created"

echo "Verify JSON"

python3 -m json.tool \
"$REG/engine-index.json" >/dev/null

echo "PASS"
