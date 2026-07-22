from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import hashlib
import json


@dataclass
class AuditEntry:

    transaction_id: str
    action: str
    result: str
    previous_hash: str = ""


    def generate_hash(self):

        payload = asdict(self)

        payload["timestamp"] = (
            datetime.now(timezone.utc)
            .isoformat()
        )

        return hashlib.sha256(
            json.dumps(
                payload,
                sort_keys=True
            ).encode()
        ).hexdigest()
