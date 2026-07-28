from __future__ import annotations


class RuntimeService:
    def status(self) -> dict:
        return {
            "service": "runtime",
            "status": "ready",
        }
