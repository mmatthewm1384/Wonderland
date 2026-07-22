from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import uuid


@dataclass
class ExecutionTransaction:

    plan_id: str

    status: str

    steps_completed: list


    def export(self):

        return {

            "id": str(uuid.uuid4()),

            **asdict(self),

            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }
