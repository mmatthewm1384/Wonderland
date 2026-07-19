#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

echo "=============================================="
echo "Certification Evidence Graph v1.1"
echo "=============================================="


MODULE_DIR="builder/python/wlplatform/wlplatform/certification"

GRAPH_FILE="$MODULE_DIR/graph.py"


cat > "$GRAPH_FILE" <<'PYTHON'
"""
Certification Evidence Graph

Creates explainable relationships between:

Engine
 -> Evidence
 -> Digest
 -> Lineage
 -> Trust
"""

from dataclasses import dataclass, field


@dataclass
class EvidenceNode:

    name: str
    node_type: str
    metadata: dict = field(default_factory=dict)


class CertificationGraph:

    def __init__(self):

        self.nodes = []


    def add_node(
        self,
        name,
        node_type,
        metadata=None
    ):

        node = EvidenceNode(
            name=name,
            node_type=node_type,
            metadata=metadata or {}
        )

        self.nodes.append(node)

        return node


    def find(
        self,
        node_type
    ):

        return [
            node
            for node in self.nodes
            if node.node_type == node_type
        ]


    def explain(self):

        return [
            {
                "name": node.name,
                "type": node.node_type,
                "metadata": node.metadata
            }
            for node in self.nodes
        ]
PYTHON


TEST_FILE="builder/python/wlplatform/tests/test_certification_evidence_graph.py"


cat > "$TEST_FILE" <<'PYTEST'
"""
Certification Evidence Graph Verification
"""


def test_graph_import():

    from wlplatform.certification.graph import (
        CertificationGraph
    )

    assert CertificationGraph is not None



def test_graph_add_engine():

    from wlplatform.certification.graph import (
        CertificationGraph
    )

    graph = CertificationGraph()

    graph.add_node(
        "runtime",
        "engine"
    )

    engines = graph.find(
        "engine"
    )

    assert len(engines) == 1



def test_graph_relationship_chain():

    from wlplatform.certification.graph import (
        CertificationGraph
    )

    graph = CertificationGraph()


    graph.add_node(
        "runtime",
        "engine"
    )

    graph.add_node(
        "runtime.json",
        "evidence"
    )

    graph.add_node(
        "sha256-runtime",
        "digest"
    )

    graph.add_node(
        "runtime-lineage",
        "lineage"
    )

    graph.add_node(
        "CERTIFIED",
        "trust"
    )


    explanation = graph.explain()


    types = [
        item["type"]
        for item in explanation
    ]


    assert "engine" in types
    assert "evidence" in types
    assert "digest" in types
    assert "lineage" in types
    assert "trust" in types
PYTEST


echo
echo "Running evidence graph verification..."

python3 -m pytest \
"$TEST_FILE" \
-v


echo
echo "Certification Evidence Graph PASS"
