#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

TARGETS=(
"builder/python/wlplatform/wlplatform/certification/adapters/registry.py"
"builder/python/wlplatform/wlplatform/certification/certifier.py"
)

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP="vault/08-Operations/backups/certification-adapter-root-${STAMP}"

mkdir -p "$BACKUP"

for file in "${TARGETS[@]}"; do
    cp "$file" "$BACKUP/"
done

python3 <<'PY'
from pathlib import Path

registry = Path(
"builder/python/wlplatform/wlplatform/certification/adapters/registry.py"
)

text = registry.read_text()

text = text.replace(
"""
    def __init__(self, name):
        self.name = name
""",
"""
    def __init__(self, name, root=None):
        self.name = name
        self.root = root
"""
)

text = text.replace(
"""
def adapters():

    return ADAPTERS
""",
"""
def adapters(root=None):

    return [
        ArtifactAdapter(
            adapter.name,
            root=root,
        )
        for adapter in ADAPTERS
    ]
"""
)

registry.write_text(text)


certifier = Path(
"builder/python/wlplatform/wlplatform/certification/certifier.py"
)

text = certifier.read_text()

text = text.replace(
"for engine in adapters():",
"for engine in adapters(root):"
)

certifier.write_text(text)

print("patched")
PY

python3 -m py_compile \
builder/python/wlplatform/wlplatform/certification/adapters/registry.py \
builder/python/wlplatform/wlplatform/certification/certifier.py

echo PASS
