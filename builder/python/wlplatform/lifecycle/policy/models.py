from dataclasses import dataclass, asdict
from datetime import datetime, timezone


@dataclass
class LifecyclePolicy:

    name: str

    version: str

    trigger: str

    condition: str

    action: str

    risk: str


    def export(self):

        return asdict(self)



@dataclass
class PolicyDecision:

    approved: bool

    action: str

    risk: str

    policy: str


    def export(self):

        return {
            **asdict(self),
            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }
