#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Engine Package Ownership Migration v1.2 =="

ROOT="/Users/wonderland/Wonderland"
cd "$ROOT"

PKG="builder/python/wlplatform/wlplatform/engines"

mkdir -p "$PKG"


echo "Creating engine implementations..."

cat > "$PKG/base.py" <<'PY'
from __future__ import annotations

from ..engine_contract import EngineContract


class BuilderEngine(EngineContract):
    name = "builder"


class GovernanceEngine(EngineContract):
    name = "governance"


class MirrorEngine(EngineContract):
    name = "mirror"


class AcademyEngine(EngineContract):
    name = "academy"
PY


cat > "$PKG/architecture.py" <<'PY'
from __future__ import annotations

from ..engine_contract import EngineContract, EngineResult


class ArchitectureEngine(EngineContract):

    name = "architecture"

    def verify(self):

        graph = (
            self.root
            /
            "vault/08-Operations/certifications/graph/certification-graph.json"
        )

        return EngineResult(
            engine=self.name,
            action="verify",
            status="PASS" if graph.exists() else "FAIL",
            details={
                "graph": str(graph),
                "exists": graph.exists(),
            },
        )
PY


cat > "$PKG/factory.py" <<'PY'
from __future__ import annotations

from pathlib import Path

from .architecture import ArchitectureEngine
from .base import (
    BuilderEngine,
    GovernanceEngine,
    MirrorEngine,
    AcademyEngine,
)
from .registry import RegistryEngine


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

    try:
        engine = ENGINE_MAP[name]
    except KeyError:
        raise ValueError(
            f"Unknown engine: {name}"
        )

    return engine(root)
PY


cat > "$PKG/__init__.py" <<'PY'
from .factory import get_engine

from .architecture import ArchitectureEngine
from .base import (
    BuilderEngine,
    GovernanceEngine,
    MirrorEngine,
    AcademyEngine,
)
from .registry import RegistryEngine


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


echo "Removing legacy import collision..."

if [[ -f builder/python/wlplatform/wlplatform/engines.py ]]; then
    mv \
    builder/python/wlplatform/wlplatform/engines.py \
    builder/python/wlplatform/wlplatform/engines.py.legacy-disabled
fi


echo
echo "Verification"

PYTHONPATH="$ROOT/builder/python/wlplatform" \
python3 - <<'PY'

from pathlib import Path

from wlplatform.engines import get_engine

for name in [
    "architecture",
    "builder",
    "governance",
    "mirror",
    "academy",
    "registry",
]:

    engine = get_engine(
        name,
        Path(".")
    )

    print(
        name,
        "PASS",
        type(engine).__name__
    )

PY


echo
echo "DONE"
