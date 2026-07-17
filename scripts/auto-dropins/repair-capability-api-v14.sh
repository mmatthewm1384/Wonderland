#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TARGET="$ROOT/builder/python/wlplatform/wlplatform/engines/capabilities.py"

echo "== Wonderland Capability API v1.4 Compatibility Repair =="

if grep -q "def list_capabilities" "$TARGET"; then
    echo "Compatibility API already exists"
else

cat >> "$TARGET" <<'PY'


# ---------------------------------------------------------
# Compatibility API
# Engine Registry v1.4
# Artifact-backed adapters
# ---------------------------------------------------------


def list_capabilities(root):

    registry = CapabilityRegistry(root)

    return registry.load()



def capability_owner(root, capability):

    registry = CapabilityRegistry(root)

    return registry.owner(capability)



def get_capability(root, capability):

    registry = CapabilityRegistry(root)

    data = registry.load()

    return data.get(capability)

PY

fi


echo
echo "Verification"

export PYTHONPATH="$ROOT/builder/python/wlplatform:$PYTHONPATH"

python3 <<PY

from pathlib import Path

from wlplatform.engines.capabilities import (
    list_capabilities,
    capability_owner,
)

root = Path("$ROOT")

caps = list_capabilities(root)

assert "runtime.start" in caps

assert capability_owner(
    root,
    "runtime.start"
) == "runtime"

print("Capability API PASS")

PY


echo
echo "DONE"
