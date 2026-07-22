from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import uuid


@dataclass
class HealingDecision:

    failure_type: str

    recoverable: bool

    action: str

    risk: str


    def export(self):

        return {
            **asdict(self),
            "id":
                str(uuid.uuid4()),
            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }
