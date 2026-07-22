from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import hashlib
import json


@dataclass
class RecoveryEvidence:

    transaction_id: str
    operation: str
    source_hash: str
    target_hash: str
    state_before: str
    state_after: str
    verification: str

    def serialize(self):

        payload = asdict(self)

        payload["timestamp"] = (
            datetime.now(timezone.utc)
            .isoformat()
        )

        payload["evidence_hash"] = hashlib.sha256(
            json.dumps(
                payload,
                sort_keys=True
            ).encode()
        ).hexdigest()

        return payload
