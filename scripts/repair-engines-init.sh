#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

cat > builder/python/wlplatform/wlplatform/engines/__init__.py <<'PY'
from __future__ import annotations

from .factory import get_engine
from .catalog import ENGINE_CATALOG
from .graph import graph

from .architecture import ArchitectureEngine
from .builder import BuilderEngine
from .governance import GovernanceEngine
from .mirror import MirrorEngine
from .academy import AcademyEngine
from .registry import RegistryEngine


__all__ = [
    "get_engine",
    "ENGINE_CATALOG",
    "graph",
    "ArchitectureEngine",
    "BuilderEngine",
    "GovernanceEngine",
    "MirrorEngine",
    "AcademyEngine",
    "RegistryEngine",
]
PY

echo "patched engines/__init__.py"


PYTHONPATH="$ROOT/builder/python/wlplatform" python3 - <<'PY'
import wlplatform.engines as engines

required = [
    "get_engine",
    "ArchitectureEngine",
    "BuilderEngine",
    "GovernanceEngine",
    "MirrorEngine",
    "AcademyEngine",
    "RegistryEngine",
]

for item in required:
    print(
        item,
        hasattr(engines, item)
    )
PY
