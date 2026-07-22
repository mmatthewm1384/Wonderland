import json
import os
import shutil
import uuid
from pathlib import Path
from datetime import datetime, timezone


class RecoveryTransaction:

    def __init__(self, root):
        self.root = Path(root)
        self.id = (
            datetime.now(timezone.utc)
            .strftime("%Y%m%dT%H%M%SZ")
            + "-"
            + uuid.uuid4().hex[:8]
        )

        self.path = (
            self.root /
            "transactions" /
            self.id
        )

    def create(self):
        self.path.mkdir(
            parents=True,
            exist_ok=False
        )

        metadata = {
            "transaction_id": self.id,
            "state": "CREATED",
            "created": datetime.now(
                timezone.utc
            ).isoformat()
        }

        (self.path / "transaction.json").write_text(
            json.dumps(
                metadata,
                indent=2
            )
        )

        return self.path

    def checkpoint(self, source):
        checkpoint = self.path / "checkpoint"

        shutil.copytree(
            source,
            checkpoint
        )

        return checkpoint

    def stage(self, source):
        staging = self.path / "staging"

        shutil.copytree(
            source,
            staging
        )

        return staging
