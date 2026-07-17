#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Engine Capability Registry Auto Drop-In =="

ROOT="${ROOT:-$HOME/Wonderland}"

cd "$ROOT"

REGISTRY_DIR="vault/05-Registry/engines"
REGISTRY_FILE="$REGISTRY_DIR/capabilities.json"

mkdir -p "$REGISTRY_DIR"

if [ ! -f "$REGISTRY_FILE" ]; then

cat > "$REGISTRY_FILE" <<'JSON'
{
  "schema_version": 1,
  "owners": {
    "runtime.start": "runtime",
    "runtime.stop": "runtime",
    "runtime.restart": "runtime",
    "runtime.sleep": "runtime",
    "runtime.wake": "runtime",

    "mirror.snapshot": "mirror",
    "mirror.restore": "mirror",

    "academy.lesson": "academy",
    "academy.chapter": "academy",

    "builder.build": "builder",

    "governance.policy": "governance",

    "registry.verify": "registry"
  }
}
JSON

echo "Created capability registry"

else

echo "Capability registry already exists"

fi

mkdir -p builder/python/wlplatform/wlplatform/engines

cat > builder/python/wlplatform/wlplatform/engines/capability_resolver.py <<'PY'
from __future__ import annotations

import json
from pathlib import Path


class CapabilityResolver:

    def __init__(self, root: Path):

        self.root = Path(root)

        self.registry = (
            self.root
            / "vault/05-Registry/engines/capabilities.json"
        )

        payload = json.loads(
            self.registry.read_text()
        )

        self.schema_version = payload.get(
            "schema_version",
            1,
        )

        self.owners = payload.get(
            "owners",
            {},
        )

    def owner(
        self,
        capability: str,
    ) -> str:

        owner = self.owners.get(
            capability,
        )

        if owner is None:

            raise ValueError(
                f"Unknown capability: {capability}"
            )

        return owner

    def capabilities(self):

        return sorted(
            self.owners.keys()
        )
PY

echo "Installed capability resolver"

python3 <<'PY'
import json
from pathlib import Path

root = Path.cwd()

path = (
    root
    / "vault/05-Registry/engines/capabilities.json"
)

payload = json.loads(
    path.read_text()
)

owners = payload["owners"]

allowed = {
    "architecture",
    "academy",
    "builder",
    "governance",
    "mirror",
    "registry",
    "runtime",
}

duplicates = set()
seen = set()

for capability in owners:

    if capability in seen:
        duplicates.add(capability)

    seen.add(capability)

bad_owners = [
    owner
    for owner in owners.values()
    if owner not in allowed
]

if duplicates:
    raise SystemExit(
        f"Duplicate capabilities: {sorted(duplicates)}"
    )

if bad_owners:
    raise SystemExit(
        f"Unknown owners: {sorted(set(bad_owners))}"
    )

print(
    f"PASS capability registry "
    f"({len(owners)} capabilities)"
)
PY

echo
echo "Suggested verification:"
echo "wl-platform engine registry --json"

echo
echo "DONE"
