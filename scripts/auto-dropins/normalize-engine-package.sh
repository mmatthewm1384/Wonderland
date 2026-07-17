#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Engine Package Normalization =="

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

cd "$ROOT"

ENGINE_DIR="builder/python/wlplatform/wlplatform"

MODULE="$ENGINE_DIR/engines.py"
PACKAGE="$ENGINE_DIR/engines"

if [[ -f "$MODULE" ]]; then
    echo "Found legacy module:"
    echo "$MODULE"

    BACKUP="${MODULE}.bak.package-normalization.$(date +%Y%m%d-%H%M%S)"

    mv "$MODULE" "$BACKUP"

    echo "Moved:"
    echo "$MODULE"
    echo "→"
    echo "$BACKUP"
fi


if [[ ! -d "$PACKAGE" ]]; then
    echo "Creating engine package"

    mkdir -p "$PACKAGE"
fi


if [[ ! -f "$PACKAGE/__init__.py" ]]; then

cat > "$PACKAGE/__init__.py" <<'PY'
from .registry import RegistryEngine
from ..engine_contract import EngineContract, EngineResult


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

    if name not in _ENGINE_MAP:
        raise ValueError(
            f"Unknown engine: {name}"
        )

    return _ENGINE_MAP[name](root)


__all__ = [
    "get_engine",
    "ArchitectureEngine",
    "BuilderEngine",
    "GovernanceEngine",
    "MirrorEngine",
    "AcademyEngine",
    "RegistryEngine",
]
PY

fi


echo "Engine package normalized"

echo
echo "Verification"

PYTHONPATH="$ROOT/builder/python/wlplatform" \
python3 - <<'PY'
from pathlib import Path

from wlplatform.engines import get_engine

engine = get_engine(
    "registry",
    Path(".")
)

print(
    engine.name,
    "IMPORT PASS"
)
PY


echo
echo "DONE"
