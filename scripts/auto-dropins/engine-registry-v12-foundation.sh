#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Engine Registry v1.2 Foundation =="

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

ENGINE_DIR="$ROOT/builder/python/wlplatform/wlplatform/engines"

mkdir -p "$ENGINE_DIR"


cat > "$ENGINE_DIR/catalog.py" <<'PY'
from __future__ import annotations


ENGINE_CATALOG = {

    "architecture": {
        "class": "ArchitectureEngine",
        "module": ".",
        "capabilities": [
            "architecture.verify",
            "graph.analysis",
        ],
        "depends_on": [],
    },

    "builder": {
        "class": "BuilderEngine",
        "module": ".",
        "capabilities": [
            "image.build",
            "artifact.create",
        ],
        "depends_on": [
            "architecture",
        ],
    },

    "governance": {
        "class": "GovernanceEngine",
        "module": ".",
        "capabilities": [
            "policy.validation",
            "compliance.verify",
        ],
        "depends_on": [
            "architecture",
        ],
    },

    "mirror": {
        "class": "MirrorEngine",
        "module": ".",
        "capabilities": [
            "snapshot",
            "restore",
        ],
        "depends_on": [
            "registry",
        ],
    },

    "academy": {
        "class": "AcademyEngine",
        "module": ".",
        "capabilities": [
            "learning",
            "documentation",
        ],
        "depends_on": [
            "registry",
        ],
    },

    "registry": {
        "class": "RegistryEngine",
        "module": ".registry",
        "capabilities": [
            "engine.discovery",
            "capability.discovery",
            "dependency.graph",
        ],
        "depends_on": [
            "architecture",
        ],
    },

}
PY


cat > "$ENGINE_DIR/graph.py" <<'PY'
from __future__ import annotations

from .catalog import ENGINE_CATALOG


def dependencies(name):

    return ENGINE_CATALOG[name]["depends_on"]


def capabilities(name):

    return ENGINE_CATALOG[name]["capabilities"]


def graph():

    return {
        name: {
            "depends_on": data["depends_on"],
            "capabilities": data["capabilities"],
        }
        for name, data in ENGINE_CATALOG.items()
    }
PY


cat > "$ENGINE_DIR/factory.py" <<'PY'
from __future__ import annotations

import importlib

from .catalog import ENGINE_CATALOG


def get_engine(name, root):

    if name not in ENGINE_CATALOG:
        raise ValueError(
            f"Unknown engine: {name}"
        )

    spec = ENGINE_CATALOG[name]

    module = importlib.import_module(
        spec["module"],
        package="wlplatform.engines",
    )

    cls = getattr(
        module,
        spec["class"],
    )

    return cls(root)
PY


cat > "$ENGINE_DIR/__init__.py" <<'PY'
from .factory import get_engine
from .catalog import ENGINE_CATALOG
from .graph import graph


__all__ = [
    "get_engine",
    "ENGINE_CATALOG",
    "graph",
]
PY


echo "Registry v1.2 foundation installed"
