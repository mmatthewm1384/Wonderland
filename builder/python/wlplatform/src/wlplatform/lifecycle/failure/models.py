from dataclasses import dataclass
from datetime import datetime, timezone
import uuid


@dataclass
class LifecycleFailure:

    component: str

    state: str

    error: str

    severity: str


    def evidence(self):

        return {
            "id": str(uuid.uuid4()),
            "component": self.component,
            "state": self.state,
            "error": self.error,
            "severity": self.severity,
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat()
        }
