"""
Wonderland Event Bus Trust Attestation Subscriber.

Produces trust assertions from verified lifecycle events.
"""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone


class TrustAttestationSubscriber:

    name = "trust_attestation"


    def __init__(
        self,
        policy: dict
    ):

        self.policy = policy


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

        event_type = event.get(
            "event_type"
        )

        trust_level = self.policy.get(
            "trust_levels",
            {}
        ).get(
            event_type,
            "UNKNOWN"
        )


        payload = {
            "event_id": event.get(
                "event_id"
            ),
            "engine": event.get(
                "engine"
            ),
            "trust_level": trust_level,
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat(),
        }


        attestation_id = hashlib.sha256(
            json.dumps(
                payload,
                sort_keys=True,
            ).encode()
        ).hexdigest()


        return {
            "attestation_id": attestation_id,
            **payload,
        }
