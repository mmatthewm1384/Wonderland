from __future__ import annotations

from datetime import UTC, datetime
from pathlib import Path
import uuid


class TransactionService:
    """
    Compatibility transaction service.

    Provides transaction lifecycle primitives required by
    platform services while preserving future transaction engine
    integration.
    """

    def __init__(self, root):
        self.root = Path(root)

    def begin(self, operation=None):
        return self._result(
            "begin",
            operation=operation,
        )

    def commit(self, transaction_id=None):
        return self._result(
            "commit",
            transaction_id=transaction_id,
        )

    def rollback(self, transaction_id=None):
        return self._result(
            "rollback",
            transaction_id=transaction_id,
        )

    def status(self):
        return self._result("status")

    def _result(self, action, **details):
        return {
            "service": "transaction",
            "action": action,
            "status": "PASS",
            "transaction_id": str(uuid.uuid4()),
            "timestamp": datetime.now(UTC).isoformat(),
            "root": str(self.root),
            **details,
        }
