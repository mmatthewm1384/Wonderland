from dataclasses import dataclass, asdict
from datetime import datetime, timezone


@dataclass
class CertificationResult:

    engine: str

    verified: bool

    policy_validated: bool

    execution_recorded: bool

    certified: bool


    def export(self):

        return {
            **asdict(self),
            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }
