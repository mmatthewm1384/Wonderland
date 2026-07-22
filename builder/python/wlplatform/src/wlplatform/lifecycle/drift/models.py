from dataclasses import dataclass, asdict
from datetime import datetime, timezone


@dataclass
class DriftResult:

    component: str

    desired: str

    actual: str

    drift: bool

    severity: str

    remediation: str


    def export(self):

        return {

            **asdict(self),

            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()

        }
