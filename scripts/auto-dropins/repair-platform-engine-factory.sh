#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Platform Engine Factory Repair =="

ROOT="/Users/wonderland/Wonderland"
PKG="$ROOT/builder/python/wlplatform/wlplatform"
ENGINES="$PKG/engines"

cd "$ROOT"

if [[ ! -d "$ENGINES" ]]; then
    echo "ERROR: engines package missing"
    exit 1
fi

echo "Patching engines/__init__.py"

cat > "$ENGINES/__init__.py" <<'PY'
from ..engine_contract import EngineContract

from .registry import RegistryEngine


class ArchitectureEngine(EngineContract):
    name = "architecture"


class BuilderEngine(EngineContract):
    name = "builder"


class GovernanceEngine(EngineContract):
    name = "governance"


class MirrorEngine(EngineContract):
    name = "mirror"


class AcademyEngine(EngineContract):
    name = "academy"



_ENGINE_MAP = {
    "architecture": ArchitectureEngine,
    "builder": BuilderEngine,
    "governance": GovernanceEngine,
    "mirror": MirrorEngine,
    "academy": AcademyEngine,
    "registry": RegistryEngine,
}


def get_engine(name, root):

    engine_class = _ENGINE_MAP.get(name)

    if engine_class is None:
        raise ValueError(
            f"Unknown engine: {name}"
        )

    return engine_class(root)


__all__ = [
    "ArchitectureEngine",
    "BuilderEngine",
    "GovernanceEngine",
    "MirrorEngine",
    "AcademyEngine",
    "RegistryEngine",
    "get_engine",
]
PY


echo "Verification..."

PYTHONPATH="$ROOT/builder/python/wlplatform" \
python3 - <<'PY'
from wlplatform.engines import get_engine

print("Factory import PASS")
print(get_engine)
PY


echo
echo "Testing wl-platform..."

"$ROOT/bin/wl-platform" engine registry --json

echo
echo "== Repair Complete =="
