#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

CAP="$ROOT/capabilities/reality.engine"

echo "Installing Deconstruction of Reality Engine v0.1"

mkdir -p \
"$CAP/engine" \
"$CAP/tests" \
"$CAP/docs" \
"$CAP/schemas" \
"$ROOT/vault/08-Operations/reality/models"


#######################################
# Capability Manifest
#######################################

cat > "$CAP/manifest.json" <<'EOF'
{
  "schema_version": "1.0",
  "capability": "reality.engine",
  "name": "Deconstruction of Reality Engine",
  "version": "0.1.0",
  "owner": "academy.matrix",
  "category": "knowledge.system",
  "status": "experimental",
  "description":
    "Framework for decomposition, modeling, simulation, and explanation of systems.",
  "certification": {
    "required": [
      "schema",
      "tests",
      "documentation",
      "reproducibility"
    ]
  }
}
EOF


#######################################
# Engine
#######################################

cat > "$CAP/engine/reality.py" <<'EOF'
class RealityEngine:

    def __init__(self):
        self.nodes = []
        self.relations = []

    def add_node(
        self,
        node_id,
        category,
        description
    ):
        self.nodes.append(
            {
                "id": node_id,
                "category": category,
                "description": description
            }
        )

    def connect(
        self,
        source,
        target,
        relation
    ):
        self.relations.append(
            {
                "source": source,
                "target": target,
                "relation": relation
            }
        )

    def export(self):
        return {
            "nodes": self.nodes,
            "relations": self.relations
        }
EOF


#######################################
# Schema
#######################################

cat > "$CAP/schemas/model.json" <<'EOF'
{
  "type": "object",
  "required": [
    "nodes",
    "relations"
  ],
  "properties": {
    "nodes": {
      "type": "array"
    },
    "relations": {
      "type": "array"
    }
  }
}
EOF


#######################################
# Test
#######################################

cat > "$CAP/tests/test_reality.py" <<'EOF'
from engine.reality import RealityEngine


def test_engine():

    engine = RealityEngine()

    engine.add_node(
        "atom",
        "primitive",
        "fundamental unit"
    )

    assert len(engine.nodes) == 1
EOF


#######################################
# Documentation
#######################################

cat > "$CAP/docs/README.md" <<'EOF'
# Deconstruction of Reality Engine

Capability:
reality.engine

Purpose:

Decompose:
- primitives
- patterns
- systems
- emergence

into explainable models.

Owner:

academy.matrix
EOF


#######################################
# Runtime Storage
#######################################

cat > \
"$ROOT/vault/08-Operations/reality/models/example.json" \
<<'EOF'
{
  "nodes": [
    {
      "id": "atom",
      "category": "primitive",
      "description": "basic unit"
    }
  ],
  "relations": []
}
EOF


#######################################
# Registry Discovery Marker
#######################################

mkdir -p "$ROOT/registry/capabilities"

cat > \
"$ROOT/registry/capabilities/reality.engine.json" \
<<'EOF'
{
  "capability": "reality.engine",
  "manifest": "capabilities/reality.engine/manifest.json",
  "owner": "academy.matrix",
  "version": "0.1.0"
}
EOF


echo
echo "================================="
echo "Reality Engine Installed"
echo "================================="
echo
echo "Next:"
echo "  wl registry discover"
echo "  wl registry verify"
echo "  wl platform certify status"
