"""
Wonderland Engine Install Events.
"""

from __future__ import annotations

from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import hashlib
import json


@dataclass(frozen=True)
class EngineInstallEvent:

    event_id: str
    event_type: str
    engine: str
    version: str
    timestamp: str
    payload: dict

    @classmethod
    def create(
        cls,
        event_type: str,
        engine: str,
        version: str,
        payload: dict,
    ):

        timestamp = datetime.now(
            timezone.utc
        ).isoformat()

        body = {
            "event_type": event_type,
            "engine": engine,
            "version": version,
            "timestamp": timestamp,
            "payload": payload,
        }

        event_id = hashlib.sha256(
            json.dumps(
                body,
                sort_keys=True,
            ).encode()
        ).hexdigest()

        return cls(
            event_id,
            event_type,
            engine,
            version,
            timestamp,
            payload,
        )

    def to_dict(self):
        return asdict(self)
