#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Engine Capability Graph Export =="

ROOT="${ROOT:-$HOME/Wonderland}"

cd "$ROOT"

mkdir -p \
    vault/08-Operations/state

cat > \
builder/python/wlplatform/wlplatform/engines/capability_graph.py <<'PY'
from __future__ import annotations

import json
from pathlib import Path


class CapabilityGraph:

    def __init__(self, root: Path):

        self.root = Path(root)

        self.registry = (
            self.root
            / "vault/05-Registry/engines/capabilities.json"
        )

    def build(self):

        payload = json.loads(
            self.registry.read_text()
        )

        owners = payload["owners"]

        nodes = []
        edges = []

        engine_nodes = set()

        for capability, owner in owners.items():

            engine_nodes.add(owner)

            nodes.append(
                {
                    "id": capability,
                    "type": "capability",
                }
            )

            edges.append(
                {
                    "from": capability,
                    "to": owner,
                    "type": "owned_by",
                }
            )

        for engine in sorted(engine_nodes):

            nodes.append(
                {
                    "id": engine,
                    "type": "engine",
                }
            )

        return {
            "schema_version": 1,
            "nodes": nodes,
            "edges": edges,
        }
PY

python3 <<'PY'
import json
from pathlib import Path

root = Path.cwd()

registry = (
    root
    / "vault/05-Registry/engines/capabilities.json"
)

payload = json.loads(
    registry.read_text()
)

owners = payload["owners"]

graph = {
    "schema_version": 1,
    "capabilities": owners,
    "count": len(owners),
}

graph_path = (
    root
    / "vault/08-Operations/state/capability-ownership.json"
)

graph_path.write_text(
    json.dumps(
        graph,
        indent=2,
    )
)

print(
    f"Exported {len(owners)} capabilities"
)
PY

echo "DONE"
