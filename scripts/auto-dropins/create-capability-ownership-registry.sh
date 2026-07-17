#!/usr/bin/env bash

set -euo pipefail

echo "== Wonderland Capability Ownership Registry =="

ROOT="${ROOT:-$HOME/Wonderland}"

TARGET="$ROOT/vault/05-Registry/engines/capability-ownership.json"

mkdir -p "$(dirname "$TARGET")"

cat > "$TARGET" <<'JSON'
{
  "schema_version": 1,
  "engine_registry": "v1.4",
  "capabilities": [
    {
      "capability": "runtime.start",
      "owner": "runtime"
    },
    {
      "capability": "runtime.stop",
      "owner": "runtime"
    },
    {
      "capability": "runtime.status",
      "owner": "runtime"
    },
    {
      "capability": "architecture.verify",
      "owner": "architecture"
    },
    {
      "capability": "builder.verify",
      "owner": "builder"
    },
    {
      "capability": "governance.verify",
      "owner": "governance"
    },
    {
      "capability": "registry.verify",
      "owner": "registry"
    },
    {
      "capability": "mirror.verify",
      "owner": "mirror"
    },
    {
      "capability": "academy.verify",
      "owner": "academy"
    }
  ]
}
JSON

echo "Created:"
echo "$TARGET"

python3 - <<PY
import json
from pathlib import Path

p = Path("$TARGET")

data = json.loads(
    p.read_text()
)

print(
    "PASS capability registry",
    len(data["capabilities"]),
    "entries"
)
PY
