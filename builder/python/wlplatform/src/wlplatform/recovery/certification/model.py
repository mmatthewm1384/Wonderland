from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import json


@dataclass
class RecoveryCertification:

    engine: str
    version: str
    certified: bool
    controls: list

    def export(self):

        return {
            **asdict(self),
            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }
