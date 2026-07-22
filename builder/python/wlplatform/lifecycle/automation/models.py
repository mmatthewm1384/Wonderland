from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import uuid


@dataclass
class Observation:

    source: str
    status: str
    details: dict


    def export(self):

        return asdict(self)



@dataclass
class AutomationRequest:

    trigger: str
    observation: dict
    policy: str
    action: str


    def export(self):

        return {
            "id": str(uuid.uuid4()),
            "trigger": self.trigger,
            "observation": self.observation,
            "policy": self.policy,
            "action": self.action,
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat()
        }
