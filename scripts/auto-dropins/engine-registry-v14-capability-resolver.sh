#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Engine Registry v1.4 Capability Resolver =="


ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

ENGINE_DIR="$ROOT/builder/python/wlplatform/wlplatform/engines"


cat > "$ENGINE_DIR/capabilities.py" <<'PY'
from __future__ import annotations

from .catalog import ENGINE_CATALOG


def capability_index():

    result = {}

    for engine, data in ENGINE_CATALOG.items():

        for capability in data["capabilities"]:

            result[capability] = {
                "owner": engine,
                "dependencies":
                    data["depends_on"],
            }

    return result



def owner(capability):

    index = capability_index()

    if capability not in index:
        raise ValueError(
            f"Unknown capability: {capability}"
        )

    return index[capability]



def list_capabilities():

    return capability_index()
PY


echo "Capability resolver installed"
