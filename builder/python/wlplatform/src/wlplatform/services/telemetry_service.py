from __future__ import annotations

from datetime import UTC, datetime
from pathlib import Path


class TelemetryService:
    """
    Compatibility telemetry service.

    Provides lifecycle and health reporting hooks without
    introducing a telemetry backend dependency.
    """

    def __init__(self, root):
        self.root = Path(root)

    def status(self):
        return self._result("status")

    def verify(self):
        return self._result("verify")

    def emit(self, event=None):
        return {
            **self._result("emit"),
            "event": event,
        }

    def _result(self, action):
        return {
            "service": "telemetry",
            "action": action,
            "status": "PASS",
            "timestamp": datetime.now(UTC).isoformat(),
            "root": str(self.root),
        }
