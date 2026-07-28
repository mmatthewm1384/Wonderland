from __future__ import annotations


class TelemetryService:
    def status(self) -> dict:
        return {
            "service": "telemetry",
            "status": "ready",
        }
