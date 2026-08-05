from pathlib import Path
import json
from datetime import datetime, timezone
import uuid


class RestoreTransaction:


    def __init__(self, root):

        self.root = Path(root)

        self.evidence_dir = (
            self.root /
            "vault" /
            "08-Operations" /
            "evidence" /
            "registry" /
            "restore"
        )


    def record(self, payload):

        self.evidence_dir.mkdir(
            parents=True,
            exist_ok=True
        )


        transaction_id = (
            uuid.uuid4().hex
        )


        record = {
            "schema_version": 1,
            "artifact": "registry-restore-transaction",
            "transaction_id": transaction_id,
            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat(),
            **payload
        }


        output = (
            self.evidence_dir /
            f"{transaction_id}.json"
        )


        output.write_text(
            json.dumps(
                record,
                indent=2
            )
        )


        return record
