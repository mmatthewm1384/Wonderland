from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

from .certification_lineage import artifact_digest


class CertificationLedger:

    def __init__(self, root: Path):

        self.root = Path(root)

        self.path = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "ledger"
            / "certification-events.jsonl"
        )

    def append(
        self,
        artifact: dict,
    ):

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        event = {
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat(),

            "engine": artifact.get(
                "engine"
            ),

            "action": artifact.get(
                "action"
            ),

            "status": artifact.get(
                "status"
            ),

            "certified": artifact.get(
                "certified",
                False,
            ),

            "digest": artifact_digest(
                artifact
            ),
        }

        with self.path.open(
            "a",
            encoding="utf-8",
        ) as handle:

            handle.write(
                json.dumps(event)
                + "\n"
            )

        return event


    def history(self):

        if not self.path.exists():
            return []

        return [
            json.loads(line)
            for line in self.path.read_text()
            .splitlines()
            if line
        ]
