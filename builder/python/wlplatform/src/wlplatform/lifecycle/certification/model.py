from dataclasses import dataclass, asdict
from datetime import datetime, timezone


@dataclass
class LifecycleCertification:

    engine: str

    version: str

    certified: bool

    trust: str

    controls: list


    def export(self):

        return {
            **asdict(self),
            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }
