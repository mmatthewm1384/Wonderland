from __future__ import annotations


class GovernanceService:
    def status(self) -> dict:
        return {
            "service": "governance",
            "status": "ready",
        }
