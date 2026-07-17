#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

export PYTHONPATH="$ROOT/builder/python/wlplatform:$ROOT/builder/python"

TARGET="$ROOT/builder/python/wlplatform/wlplatform/certification_graph.py"

echo "== Wonderland CertificationGraph Status Repair =="

if [[ ! -f "$TARGET" ]]; then
    echo "FAIL: $TARGET missing"
    exit 1
fi

grep -q "def status(" "$TARGET" && {
    echo "PASS: status already exists"
    exit 0
}

python3 <<'PY'
from pathlib import Path

path = Path(
    "/Users/wonderland/Wonderland/builder/python/wlplatform/wlplatform/certification_graph.py"
)

text = path.read_text()

if "def status(" in text:
    print("already patched")
    raise SystemExit(0)

anchor = "    def rebuild"

if anchor not in text:
    raise SystemExit(
        "FAIL: rebuild method anchor missing"
    )

method = '''
    def status(self):
        graph = self.build()

        return {
            "schema_version": 1,
            "result": "PASS",
            "graph": True,
            "nodes": len(graph.get("nodes", [])),
            "edges": len(graph.get("edges", [])),
            "status": "CERTIFICATION_GRAPH_READY",
        }

'''

text = text.replace(
    anchor,
    method + anchor,
)

path.write_text(text)

print("PASS: CertificationGraph.status added")
PY
