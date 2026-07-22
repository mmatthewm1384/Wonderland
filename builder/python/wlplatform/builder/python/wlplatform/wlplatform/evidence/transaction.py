"""
Wonderland Evidence Transaction Contract.

Defines immutable evidence transaction records used by
certification, verification, and audit workflows.
"""

from __future__ import annotations

from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import hashlib
import json
from typing import Any


class EvidenceTransactionError(Exception):
    """Raised when an evidence transaction is invalid."""


@dataclass(frozen=True)
class EvidenceTransaction:
    """
    Immutable evidence transaction record.
    """

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
    ) -> "EvidenceTransaction":

        if not evidence_type:
            raise EvidenceTransactionError(
                "Evidence type required"
            )

        if not artifact:
            raise EvidenceTransactionError(
                "Artifact required"
            )

        if not digest:
            raise EvidenceTransactionError(
                "Digest required"
            )

        created_at = datetime.now(
            timezone.utc
        ).isoformat()

        payload = {
            "evidence_type": evidence_type,
            "artifact": artifact,
            "digest": digest,
            "created_at": created_at,
            "metadata": metadata or {},
        }

        transaction_id = hashlib.sha256(
            json.dumps(
                payload,
                sort_keys=True,
            ).encode()
        ).hexdigest()

        return cls(
            transaction_id=transaction_id,
            evidence_type=evidence_type,
            artifact=artifact,
            digest=digest,
            created_at=created_at,
            metadata=metadata or {},
        )

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)

    def verify(self) -> bool:
        payload = {
            "evidence_type": self.evidence_type,
            "artifact": self.artifact,
            "digest": self.digest,
            "created_at": self.created_at,
            "metadata": self.metadata,
        }

        expected = hashlib.sha256(
            json.dumps(
                payload,
                sort_keys=True,
            ).encode()
        ).hexdigest()

        return expected == self.transaction_id
