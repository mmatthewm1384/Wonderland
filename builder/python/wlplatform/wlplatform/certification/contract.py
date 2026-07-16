from datetime import datetime, timezone


class CertificationResult:

    def __init__(
        self,
        engine,
        status,
        evidence=None,
        details=None
    ):
        self.engine = engine
        self.status = status
        self.evidence = evidence or []
        self.details = details or {}
        self.timestamp = datetime.now(
            timezone.utc
        ).isoformat()


    def json(self):
        return {
            "engine": self.engine,
            "status": self.status,
            "evidence": self.evidence,
            "details": self.details,
            "timestamp": self.timestamp
        }



class CertificationContract:

    name = None


    def verify(self):
        raise NotImplementedError


    def certify(self):

        result = self.verify()

        return CertificationResult(
            engine=self.name,
            status=result.status,
            evidence=result.evidence,
            details=result.details
        )
