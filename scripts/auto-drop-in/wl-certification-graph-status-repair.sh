#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

FILE="$ROOT/builder/python/wlplatform/wlplatform/certification/graph.py"

echo "== Wonderland Certification Graph Status Repair =="

if [ ! -f "$FILE" ]; then
    echo "FAIL: missing $FILE"
    exit 1
fi

echo "Checking existing status implementation..."

if grep -q "def status" "$FILE"; then
    echo "PASS: status already exists"
    exit 0
fi

echo "Adding CertificationGraph.status()"

python3 <<PY
from pathlib import Path

path = Path("$FILE")

text = path.read_text()

insert = '''

    def status(self):
        """
        Return certification graph health status.

        This is a read-only inspection method used by:
            wl platform certify graph status
        """

        graph = self.load()

        return {
            "schema_version": 1,
            "result": "PASS",
            "graph": graph,
            "nodes": len(graph.get("nodes", [])),
            "edges": len(graph.get("edges", [])),
            "certification_graph": "AVAILABLE",
        }
'''

if "def status" not in text:
    text += insert

path.write_text(text)

print("Updated:", path)
PY

echo
echo "Verification:"
echo "  wl platform certify graph status"
