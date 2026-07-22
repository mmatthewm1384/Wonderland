from __future__ import annotations

from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import hashlib
import json
from typing import Any


class EvidenceTransactionError(Exception):
    pass


@dataclass(frozen=True)
class EvidenceTransaction:
    transaction_id: str
    evidence_type: str
    artifact: str
    digest: str
    created_at: str
    metadata: dict[str, Any]

    @classmethod
    def create(
        cls,
        evidence_type: str,
        artifact: str,
        digest: str,
        metadata: dict[str, Any] | None = None,
    ):
        created_at = datetime.now(
            timezone.utc
        ).isoformat()

        metadata = metadata or {}

        payload = {
            "evidence_type": evidence_type,
            "artifact": artifact,
            "digest": digest,
            "created_at": created_at,
            "metadata": metadata,
        }

        transaction_id = hashlib.sha256(
            json.dumps(
                payload,
                sort_keys=True
            ).encode()
        ).hexdigest()

        return cls(
            transaction_id,
            evidence_type,
            artifact,
            digest,
            created_at,
            metadata,
        )

    def verify(self):
        payload = {
            "evidence_type": self.evidence_type,
            "artifact": self.artifact,
            "digest": self.digest,
            "created_at": self.created_at,
            "metadata": self.metadata,
        }

        return hashlib.sha256(
            json.dumps(
                payload,
                sort_keys=True
            ).encode()
        ).hexdigest() == self.transaction_id

    def to_dict(self):
        return asdict(self)
