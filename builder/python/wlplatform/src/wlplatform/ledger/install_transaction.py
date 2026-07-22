"""
Wonderland Engine Install Transaction Ledger.

Provides append-only operational records.
"""

from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
import hashlib
import json
import uuid


class InstallLedgerError(Exception):
    pass


class InstallTransaction:

    def __init__(
        self,
        operation: str,
        engine: str,
        files_changed: list[str],
        verification: dict,
        certification: dict,
        rollback: dict,
    ):

        self.timestamp = datetime.now(
            timezone.utc
        ).isoformat()

        self.operation = operation
        self.engine = engine
        self.files_changed = files_changed
        self.verification = verification
        self.certification = certification
        self.rollback = rollback

        payload = {
            "operation": operation,
            "engine": engine,
            "timestamp": self.timestamp,
            "files_changed": files_changed,
        }

        self.transaction_id = hashlib.sha256(
            json.dumps(
                payload,
                sort_keys=True
            ).encode()
        ).hexdigest()

    def to_dict(self):

        return {
            "transaction_id": self.transaction_id,
            "operation": self.operation,
            "engine": self.engine,
            "timestamp": self.timestamp,
            "files_changed": self.files_changed,
            "verification": self.verification,
            "certification": self.certification,
            "rollback": self.rollback,
        }


def append_transaction(
    ledger_path: str,
    transaction: InstallTransaction,
):

    path = Path(ledger_path)

    path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    with path.open(
        "a",
        encoding="utf-8",
    ) as file:

        file.write(
            json.dumps(
                transaction.to_dict()
            )
            + "\n"
        )
