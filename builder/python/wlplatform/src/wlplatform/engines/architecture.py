from __future__ import annotations

from ..engine_contract import EngineContract, EngineResult


class ArchitectureEngine(EngineContract):

    name = "architecture"

    def verify(self):

        graph = (
            self.root
            /
            "vault/08-Operations/certifications/graph/certification-graph.json"
        )

        return EngineResult(
            engine=self.name,
            action="verify",
            status="PASS" if graph.exists() else "FAIL",
            details={
                "graph": str(graph),
                "exists": graph.exists(),
            },
        )
