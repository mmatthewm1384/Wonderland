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
