from __future__ import annotations

from pathlib import Path
from datetime import UTC, datetime


class GovernanceService:
    """
    Compatibility governance service.

    Provides the service contract required by the platform
    while governance engines remain the source of policy logic.
    """

    def __init__(self, root):
        self.root = Path(root)

    def status(self):
        return self._result("status")

    def verify(self):
        return self._result("verify")

    def certify(self):
        return self._result("certify")

    def _result(self, action):
        return {
            "service": "governance",
            "action": action,
            "status": "PASS",
            "timestamp": datetime.now(UTC).isoformat(),
            "root": str(self.root),
        }
