#!/usr/bin/env bash
set -euo pipefail

echo "== Add Engine Metadata v1.1 =="

ROOT="/Users/wonderland/Wonderland"
PKG="$ROOT/builder/python/wlplatform/wlplatform"

cd "$ROOT"

mkdir -p "$PKG/engines"

cat > "$PKG/engines/metadata.py" <<'PY'
from dataclasses import dataclass, asdict


@dataclass
class EngineMetadata:

    name: str
    version: str
    owner: str
    capabilities: list[str]

    def to_dict(self):
        return asdict(self)
PY


echo "Metadata module created"

PYTHONPATH="$ROOT/builder/python/wlplatform" \
python3 - <<'PY'
from wlplatform.engines.metadata import EngineMetadata

print(
    EngineMetadata(
        "registry",
        "1.1.0",
        "platform.registry",
        [
            "command-discovery",
            "manifest-validation"
        ]
    ).to_dict()
)

print("PASS")
PY
