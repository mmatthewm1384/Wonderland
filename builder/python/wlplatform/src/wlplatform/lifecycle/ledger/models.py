from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import uuid


@dataclass
class LifecycleEvent:

    event: str

    source_state: str

    target_state: str

    component: str

    result: str

    evidence: dict


    def serialize(self):

        return {
            "id": str(uuid.uuid4()),
            "event": self.event,
            "source_state": self.source_state,
            "target_state": self.target_state,
            "component": self.component,
            "result": self.result,
            "evidence": self.evidence,
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat()
        }
