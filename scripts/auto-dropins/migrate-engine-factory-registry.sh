#!/usr/bin/env bash
set -euo pipefail

echo "== Engine Factory Registry Migration =="

ROOT="/Users/wonderland/Wonderland"

FACTORY="$ROOT/builder/python/wlplatform/wlplatform/engines/factory.py"

cat > "$FACTORY" <<'PY'
import json
import importlib
from pathlib import Path


INDEX = (
    Path.cwd()
    /
    "vault/05-Registry/engines/engine-index.json"
)


def load_engine_registry():

    data = json.loads(
        INDEX.read_text()
    )

    return data["engines"]



def get_engine(name, root):

    for entry in load_engine_registry():

        if entry["name"] == name:

            module = importlib.import_module(
                entry["module"]
            )

            cls = getattr(
                module,
                entry["class"]
            )

            return cls(root)

    raise ValueError(
        f"Unknown engine: {name}"
    )
PY


echo "PASS"
