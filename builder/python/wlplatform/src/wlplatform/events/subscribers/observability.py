"""
Wonderland Event Bus Observability Subscriber.

Tracks:
- lifecycle events
- event counts
- failures
- certification transitions
"""

from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
import json


class ObservabilitySubscriber:

    name = "observability"


    def handles(self, event: dict) -> bool:

        return event.get(
            "event_type",
            ""
        ).startswith(
            "ENGINE_"
        )


    def process(self, event: dict):

        record = {
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat(),

            "event_id": event.get(
                "event_id"
            ),

            "event_type": event.get(
                "event_type"
            ),

            "engine": event.get(
                "engine"
            ),

            "status": self._status(event),
        }

        return record


    def _status(self, event):

        event_type = event.get(
            "event_type",
            ""
        )

        if "FAILED" in event_type:
            return "FAILURE"

        if "COMPLETED" in event_type:
            return "COMPLETED"

        return "ACTIVE"
