
from __future__ import annotations

import json
from pathlib import Path


class CertificationGraph:

    VERSION = 1


    def __init__(self, root: Path):

        self.root = root.resolve()

        self.output = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "graph"
            / "certification-graph.json"
        )





    def status(self):

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


    def build(self):

        from .certification_registry import CertificationRegistry

        registry = CertificationRegistry(
            self.root
        )

        active = registry.active()

        nodes = {}

        for name in sorted(active):
            nodes[name] = active[name]

        return {
            "schema_version": 1,
            "nodes": nodes,
            "edges": [],
            "lineage": {
                "source": "certification-registry",
                "active_only": True
            }
        }


    def rebuild(self):

        from .certification_registry import CertificationRegistry

        registry = CertificationRegistry(
            self.root
        )

        active = registry.active()

        nodes = {}

        for name in sorted(active):
            nodes[name] = active[name]

        graph = {
            "schema_version": 1,
            "nodes": nodes,
            "lineage": {
                "source": "certification-registry",
                "active_only": True
            }
        }

        self.output.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        self.output.write_text(
            json.dumps(
                graph,
                indent=2,
                sort_keys=True
            ),
            encoding="utf-8"
        )

        return graph

