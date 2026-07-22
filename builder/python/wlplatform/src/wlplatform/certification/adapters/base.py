from ..contract import CertificationResult


class EngineAdapter:

    name = None


    def verify(self):
        return CertificationResult(
            engine=self.name,
            status="PASS",
            evidence=[],
            details={
                "adapter":"default"
            }
        )


    def certify(self):

        return self.verify()
