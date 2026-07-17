#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

TARGET="$ROOT/builder/python/wlplatform/wlplatform/engines/graph.py"


cat > "$TARGET" <<'PY'
from pathlib import Path
import json


class EngineGraph:

    def __init__(self, root):

        self.root = Path(root)

        self.path = (
            self.root
            /
            "vault/05-Registry/engines/engine-graph.json"
        )


    def load(self):

        if not self.path.exists():
            return {
                "nodes": [],
                "edges": []
            }

        return json.loads(
            self.path.read_text()
        )


    def dependencies(self, engine):

        graph = self.load()

        return [
            edge
            for edge in graph["edges"]
            if edge["from"] == engine
        ]


    def dependents(self, engine):

        graph = self.load()

        return [
            edge
            for edge in graph["edges"]
            if edge["to"] == engine
        ]
PY


python3 -m compileall "$TARGET"

echo "PASS"
