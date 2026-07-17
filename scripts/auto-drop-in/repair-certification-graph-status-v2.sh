#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"
TARGET="$ROOT/builder/python/wlplatform/wlplatform/certification_graph.py"

echo "== Wonderland CertificationGraph.status Repair v2 =="

python3 <<'PY'
from pathlib import Path

path = Path(
    "/Users/wonderland/Wonderland/builder/python/wlplatform/wlplatform/certification_graph.py"
)

text = path.read_text()

start = text.index("    def status(self):")
end = text.index("    def rebuild(self):")

replacement = '''    def status(self):

        if not self.output.exists():
            return {
                "schema_version": 1,
                "result": "FAIL",
                "graph": False,
                "status": "CERTIFICATION_GRAPH_MISSING",
                "path": str(self.output),
            }

        graph = json.loads(
            self.output.read_text(
                encoding="utf-8"
            )
        )

        nodes = graph.get(
            "nodes",
            {}
        )

        return {
            "schema_version": 1,
            "result": "PASS",
            "graph": True,
            "nodes": len(nodes),
            "edges": 0,
            "status": "CERTIFICATION_GRAPH_READY",
            "path": str(self.output),
        }

'''

text = (
    text[:start]
    + replacement
    + text[end:]
)

path.write_text(text)

print("PASS: CertificationGraph.status repaired")
PY
