"""
Wonderland Event Bus Evidence Generation Subscriber.

Creates deterministic evidence records
from trusted engine events.
"""

from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path

import hashlib
import json


class EvidenceGenerationSubscriber:

    name = "evidence_generation"


    def handles(
        self,
        event: dict
    ) -> bool:

        return event.get(
            "event_type",
            ""
        ).startswith(
            "ENGINE_"
        )


    def process(
        self,
        event: dict
    ) -> dict:

        created = datetime.now(
            timezone.utc
        ).isoformat()

        evidence_payload = {
            "event_id": event.get(
                "event_id"
            ),
            "event_type": event.get(
                "event_type"
            ),
            "engine": event.get(
                "engine"
            ),
            "created_at": created,
            "payload": event.get(
                "payload",
                {}
            ),
        }


        serialized = json.dumps(
            evidence_payload,
            sort_keys=True,
        )


        digest = hashlib.sha256(
            serialized.encode()
        ).hexdigest()


        return {
            "evidence_id": digest,
            "digest": digest,
            "type": "engine_event_evidence",
            "created_at": created,
            "source_event": event.get(
                "event_id"
            ),
            "engine": event.get(
                "engine"
            ),
            "payload": evidence_payload,
        }
