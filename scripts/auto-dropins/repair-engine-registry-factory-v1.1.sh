#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Engine Registry Factory Adapter v1.1 =="

ROOT="/Users/wonderland/Wonderland"
cd "$ROOT"

TARGET="builder/python/wlplatform/wlplatform/engines/factory.py"

if [[ ! -f "$TARGET" ]]; then
    echo "Missing:"
    echo "$TARGET"
    exit 1
fi

cp "$TARGET" \
"${TARGET}.bak.registry-factory-$(date +%Y%m%d-%H%M%S)"

cat > "$TARGET" <<'PY'
from __future__ import annotations

from pathlib import Path

from .architecture import ArchitectureEngine
from .registry import RegistryEngine
from ..engines import (
    BuilderEngine,
    GovernanceEngine,
    MirrorEngine,
    AcademyEngine,
)


ENGINE_MAP = {
    "architecture": ArchitectureEngine,
    "builder": BuilderEngine,
    "governance": GovernanceEngine,
    "mirror": MirrorEngine,
    "academy": AcademyEngine,
    "registry": RegistryEngine,
}


def get_engine(
    name: str,
    root: Path,
):

    if name not in ENGINE_MAP:
        raise ValueError(
            f"Unknown engine: {name}"
        )

    return ENGINE_MAP[name](root)
PY


echo "Factory normalized"

echo
echo "Verification"

PYTHONPATH="$ROOT/builder/python/wlplatform" \
python3 - <<'PY'
from pathlib import Path

from wlplatform.engines.factory import get_engine

engine = get_engine(
    "registry",
    Path(".")
)

print(
    "registry factory PASS:",
    type(engine).__name__
)
PY

echo
echo "DONE"
