from dataclasses import dataclass, asdict
from datetime import datetime, timezone


@dataclass
class VerificationResult:

    expected: str

    actual: str

    verified: bool

    result: str

    recovery_required: bool


    def export(self):

        return {
            **asdict(self),
            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }
