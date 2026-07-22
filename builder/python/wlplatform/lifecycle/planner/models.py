from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import uuid


@dataclass
class ActionStep:

    name: str

    operation: str

    target: str

    order: int



@dataclass
class ExecutionPlan:

    action: str

    steps: list

    rollback: dict


    def export(self):

        return {

            "id": str(uuid.uuid4()),

            "action": self.action,

            "steps": [
                asdict(step)
                for step in self.steps
            ],

            "rollback": self.rollback,

            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }
