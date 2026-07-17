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

