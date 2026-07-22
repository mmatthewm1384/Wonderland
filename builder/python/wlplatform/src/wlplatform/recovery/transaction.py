from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import os
import uuid


class EvidenceTransaction:

    def __init__(self, root):

        self.root = Path(root)

        self.entries = self.root / "entries"
        self.digests = self.root / "digests"
        self.staging = self.root / "staging"
        self.transactions = self.root / "transactions"

        for directory in (
            self.entries,
            self.digests,
            self.staging,
            self.transactions,
        ):
            directory.mkdir(
                parents=True,
                exist_ok=True
            )

    def commit(
        self,
        engine,
        status
    ):

        txid = str(uuid.uuid4())

        timestamp = datetime.now(
            timezone.utc
        ).strftime(
            "%Y%m%dT%H%M%SZ"
        )

        entry = {
            "transaction_id": txid,
            "timestamp": timestamp,
            "engine": engine,
            "status": status
        }

        stage_json = (
            self.staging /
            f"{txid}.json"
        )

        payload = json.dumps(
            entry,
            indent=2
        )

        stage_json.write_text(
            payload
        )

        digest = hashlib.sha256(
            payload.encode()
        ).hexdigest()

        final_entry = (
            self.entries /
            f"{timestamp}.json"
        )

        os.replace(
            stage_json,
            final_entry
        )

        digest_file = (
            self.digests /
            f"{timestamp}.sha256"
        )

        digest_file.write_text(
            digest + "\n"
        )

        return {
            "transaction_id": txid,
            "digest": digest,
            "entry": str(final_entry)
        }
