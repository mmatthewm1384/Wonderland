from __future__ import annotations

from ..engine_contract import (
    EngineContract,
    EngineResult,
)


class RuntimeEngine(EngineContract):

    name = "runtime"


    def verify(self):

        return EngineResult(
            engine=self.name,
            action="verify",
            status="PASS",
            details={
                "runtime": "active",
            },
        )


    def certify(self):

        return self.verify()
