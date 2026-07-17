#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Engine Package Normalization =="

ROOT="/Users/wonderland/Wonderland"
PKG="$ROOT/builder/python/wlplatform/wlplatform"
ENG="$PKG/engines"

cd "$ROOT"

mkdir -p "$ENG"


echo "Creating engine modules..."

cat > "$ENG/architecture.py" <<'PY'
from ..engine_contract import EngineContract, EngineResult


class ArchitectureEngine(EngineContract):

    name = "architecture"

    def verify(self):

        graph = (
            self.root /
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


cat > "$ENG/builder.py" <<'PY'
from ..engine_contract import EngineContract


class BuilderEngine(EngineContract):
    name = "builder"
PY


cat > "$ENG/governance.py" <<'PY'
from ..engine_contract import EngineContract


class GovernanceEngine(EngineContract):
    name = "governance"
PY


cat > "$ENG/mirror.py" <<'PY'
from ..engine_contract import EngineContract


class MirrorEngine(EngineContract):
    name = "mirror"
PY


cat > "$ENG/academy.py" <<'PY'
from ..engine_contract import EngineContract


class AcademyEngine(EngineContract):
    name = "academy"
PY


echo "Creating factory..."

cat > "$ENG/factory.py" <<'PY'
from .architecture import ArchitectureEngine
from .builder import BuilderEngine
from .governance import GovernanceEngine
from .mirror import MirrorEngine
from .academy import AcademyEngine
from .registry import RegistryEngine


ENGINE_REGISTRY = {
    "architecture": ArchitectureEngine,
    "builder": BuilderEngine,
    "governance": GovernanceEngine,
    "mirror": MirrorEngine,
    "academy": AcademyEngine,
    "registry": RegistryEngine,
}


def get_engine(name, root):

    engine = ENGINE_REGISTRY.get(name)

    if engine is None:
        raise ValueError(
            f"Unknown engine: {name}"
        )

    return engine(root)
PY


echo "Creating package API..."

cat > "$ENG/__init__.py" <<'PY'
from .factory import get_engine

from .architecture import ArchitectureEngine
from .builder import BuilderEngine
from .governance import GovernanceEngine
from .mirror import MirrorEngine
from .academy import AcademyEngine
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


echo "Removing legacy collision..."

if [[ -f "$PKG/engines.py" ]]; then

    mv \
      "$PKG/engines.py" \
      "$PKG/engines.py.legacy-backup"

fi


echo "Verification..."

PYTHONPATH="$ROOT/builder/python/wlplatform" \
python3 - <<'PY'
from wlplatform.engines import get_engine

print("Engine package import PASS")
print(get_engine("registry", "."))
PY


echo "CLI verification..."

"$ROOT/bin/wl-platform" engine registry --json


echo "== Engine Package Normalization Complete =="
