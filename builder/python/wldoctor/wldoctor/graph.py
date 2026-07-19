from __future__ import annotations

from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any


@dataclass
class EvidenceNode:
    id: str
    engine: str
    status: str
    certified: bool
    artifact: str | None = None
    digest: str | None = None

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


class EvidenceGraph:

    def __init__(self, root: Path):
        self.root = root.resolve()
        self.nodes: list[EvidenceNode] = []
        self.edges: list[dict[str, str]] = []

    def add_node(
        self,
        node: EvidenceNode,
    ) -> None:
        self.nodes.append(node)

    def add_edge(
        self,
        source: str,
        target: str,
        relationship: str,
    ) -> None:
        self.edges.append(
            {
                "source": source,
                "target": target,
                "relationship": relationship,
            }
        )

    def as_dict(self) -> dict[str, Any]:
        return {
            "schema_version": 1,
            "engine": "wonderland-evidence-graph",
            "nodes": [
                node.as_dict()
                for node in self.nodes
            ],
            "edges": self.edges,
        }
