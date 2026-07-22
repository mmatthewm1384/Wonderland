from __future__ import annotations

from ..engine_contract import (
    EngineContract,
    EngineResult,
)


class MirrorEngine(EngineContract):

    name = "mirror"


    def verify(self):

        return EngineResult(
            engine=self.name,
            action="verify",
            status="PASS",
            details={
                "mirror": "active",
            },
        )


    def certify(self):

        return self.verify()
