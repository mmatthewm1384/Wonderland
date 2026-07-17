#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "== Wonderland Engine Registry v1.2 Migration =="

REGISTRY_DIR="$ROOT/vault/05-Registry/engines"
ENGINE_DIR="$ROOT/builder/python/wlplatform/wlplatform/engines"

mkdir -p "$REGISTRY_DIR"
mkdir -p "$ENGINE_DIR"

echo "Creating engine ownership graph..."

cat > "$REGISTRY_DIR/engine-graph.json" <<'EOF'
{
  "schema_version": "1.2",
  "graph_type": "engine-capability-ownership",

  "nodes": [
    {
      "id": "architecture",
      "type": "engine",
      "owner": "wlarchitecture"
    },
    {
      "id": "builder",
      "type": "engine",
      "owner": "wlbuilder"
    },
    {
      "id": "governance",
      "type": "engine",
      "owner": "wlgovernance"
    },
    {
      "id": "registry",
      "type": "engine",
      "owner": "wlplatform"
    },
    {
      "id": "mirror",
      "type": "engine",
      "owner": "wlmirror"
    },
    {
      "id": "academy",
      "type": "engine",
      "owner": "wlacademy"
    }
  ],

  "edges": [
    {
      "from": "registry",
      "to": "architecture",
      "relationship": "discovers"
    },
    {
      "from": "registry",
      "to": "builder",
      "relationship": "discovers"
    },
    {
      "from": "registry",
      "to": "governance",
      "relationship": "discovers"
    },
    {
      "from": "registry",
      "to": "mirror",
      "relationship": "discovers"
    },
    {
      "from": "registry",
      "to": "academy",
      "relationship": "discovers"
    }
  ]
}
EOF


echo "Creating graph loader..."

cat > "$ENGINE_DIR/graph.py" <<'PY'
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


    def nodes(self):

        return self.load().get(
            "nodes",
            []
        )


    def edges(self):

        return self.load().get(
            "edges",
            []
        )


    def dependencies(self, engine):

        return [
            edge
            for edge in self.edges()
            if edge["from"] == engine
        ]


    def dependents(self, engine):

        return [
            edge
            for edge in self.edges()
            if edge["to"] == engine
        ]
PY


echo "Updating engine package exports..."

INIT="$ENGINE_DIR/__init__.py"

if ! grep -q "EngineGraph" "$INIT"; then

cat >> "$INIT" <<'PY'

from .graph import EngineGraph
PY

fi


echo "Validation..."

python3 -m json.tool \
"$REGISTRY_DIR/engine-graph.json" \
>/dev/null


python3 -m compileall \
"$ENGINE_DIR/graph.py" \
>/dev/null


echo
echo "Engine Registry v1.2 Migration PASS"

echo
echo "Created:"
echo "  $REGISTRY_DIR/engine-graph.json"
echo "  $ENGINE_DIR/graph.py"
