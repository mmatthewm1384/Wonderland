#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TARGET="$ROOT/builder/python/wlplatform/wlplatform/engines/catalog.py"

echo "== Runtime Capability Registration Repair =="

grep -n '"runtime"' "$TARGET" && {
    echo "runtime already registered"
    exit 0
}

cp "$TARGET" "$TARGET.bak.$(date +%Y%m%d-%H%M%S)"

cat <<'EOF'

Runtime engine missing from catalog.

Manual catalog update required.

EOF
