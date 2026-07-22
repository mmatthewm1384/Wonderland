from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import hashlib
import json


@dataclass
class ApprovalRequest:

    transaction_id: str
    operation: str
    target: str
    risk: str


@dataclass
class ApprovalDecision:

    transaction_id: str
    decision: str
    approver: str
    reason: str

    def evidence(self):

        payload = asdict(self)

        payload["timestamp"] = (
            datetime.now(timezone.utc)
            .isoformat()
        )

        payload["hash"] = hashlib.sha256(
            json.dumps(
                payload,
                sort_keys=True
            ).encode()
        ).hexdigest()

        return payload
