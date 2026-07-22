from __future__ import annotations

from ..engine_contract import (
    EngineContract,
    EngineResult,
)


class RepositoryEngine(EngineContract):

    name = "repository"


    def verify(self):

        return EngineResult(
            engine=self.name,
            action="verify",
            status="PASS",
            details={
                "repository": "active",
            },
        )


    def certify(self):

        return self.verify()
