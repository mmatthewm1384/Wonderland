#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "== Wonderland Engine Registry v1.4 Capability Artifact =="

REGISTRY="$ROOT/vault/05-Registry/engines"

mkdir -p "$REGISTRY"


cat > "$REGISTRY/capabilities.json" <<'EOF'
{
  "schema_version": 1,
  "capabilities": {
    "runtime.start": {
      "owner": "runtime",
      "engine": "runtime"
    },
    "runtime.stop": {
      "owner": "runtime",
      "engine": "runtime"
    },
    "runtime.status": {
      "owner": "runtime",
      "engine": "runtime"
    },
    "registry.verify": {
      "owner": "registry",
      "engine": "registry"
    },
    "registry.certify": {
      "owner": "registry",
      "engine": "registry"
    },
    "architecture.verify": {
      "owner": "architecture",
      "engine": "architecture"
    },
    "builder.verify": {
      "owner": "builder",
      "engine": "builder"
    },
    "governance.verify": {
      "owner": "governance",
      "engine": "governance"
    },
    "mirror.verify": {
      "owner": "mirror",
      "engine": "mirror"
    },
    "academy.verify": {
      "owner": "academy",
      "engine": "academy"
    }
  }
}
EOF


cat > "$ROOT/builder/python/wlplatform/wlplatform/engines/capabilities.py" <<'EOF'
from __future__ import annotations

import json
from pathlib import Path


class CapabilityRegistry:

    def __init__(self, root: Path):
        self.root = Path(root)

        self.path = (
            self.root
            /
            "vault/05-Registry/engines/capabilities.json"
        )

    def load(self):

        if not self.path.exists():
            return {}

        payload = json.loads(
            self.path.read_text()
        )

        return payload.get(
            "capabilities",
            {}
        )


    def owner(self, capability: str):

        registry = self.load()

        entry = registry.get(capability)

        if entry is None:
            raise ValueError(
                f"Unknown capability: {capability}"
            )

        return entry["owner"]
EOF


cat > "$ROOT/scripts/auto-dropins/verify-engine-registry-v14.sh" <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

export PYTHONPATH="$ROOT/builder/python/wlplatform:$PYTHONPATH"

python3 <<PY

from pathlib import Path

from wlplatform.engines.capabilities import CapabilityRegistry

root = Path("$ROOT")

registry = CapabilityRegistry(root)

assert registry.owner(
    "runtime.start"
) == "runtime"

assert registry.owner(
    "registry.verify"
) == "registry"

print("Capability resolver PASS")

PY

EOF


chmod +x "$ROOT/scripts/auto-dropins/verify-engine-registry-v14.sh"


echo
echo "Verification"

"$ROOT/scripts/auto-dropins/verify-engine-registry-v14.sh"

echo
echo "DONE"
