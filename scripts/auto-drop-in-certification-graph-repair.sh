#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"
FILE="$ROOT/builder/python/wlplatform/wlplatform/certification_graph.py"

echo "== Wonderland Certification Graph API Repair =="

if [ ! -f "$FILE" ]; then
    echo "ERROR: Missing:"
    echo "$FILE"
    exit 1
fi

cp "$FILE" "$FILE.backup.$(date +%Y%m%d%H%M%S)"

python3 - <<'PY'
from pathlib import Path

path = Path(
    "/Users/wonderland/Wonderland/builder/python/wlplatform/wlplatform/certification_graph.py"
)

text = path.read_text()

if "def build(self):" in text:
    print("build() already exists")
    raise SystemExit(0)

needle = "    def rebuild(self):\n"

insert = '''
    def build(self):

        from .certification_registry import CertificationRegistry

        registry = CertificationRegistry(
            self.root
        )

        active = registry.active()

        nodes = {}

        for name in sorted(active):
            nodes[name] = active[name]

        return {
            "schema_version": 1,
            "nodes": nodes,
            "edges": [],
            "lineage": {
                "source": "certification-registry",
                "active_only": True
            }
        }


'''

if needle not in text:
    raise SystemExit(
        "Could not locate rebuild() insertion point"
    )

text = text.replace(
    needle,
    insert + needle
)

path.write_text(text)

print("Installed CertificationGraph.build()")
PY


echo
echo "== Syntax Check =="

python3 -m py_compile \
"$FILE"


echo
echo "== Import Check =="

PYTHONPATH="$ROOT/builder/python:$ROOT" \
python3 - <<'PY'
from pathlib import Path
from wlplatform.certification_graph import CertificationGraph

g = CertificationGraph(
    Path("/Users/wonderland/Wonderland")
)

print(g.status())
PY


echo
echo "== Complete =="
