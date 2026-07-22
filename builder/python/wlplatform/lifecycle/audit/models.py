from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import hashlib
import json
import uuid


@dataclass
class AuditEvent:

    event_type: str

    action: str

    status: str

    correlation_id: str

    previous_hash: str = ""


    def hash(self):

        payload = json.dumps(
            asdict(self),
            sort_keys=True
        )

        return hashlib.sha256(
            payload.encode()
        ).hexdigest()


    def export(self):

        return {

            **asdict(self),

            "id":
                str(uuid.uuid4()),

            "hash":
                self.hash(),

            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }
