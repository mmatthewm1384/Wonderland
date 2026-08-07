from __future__ import annotations

from pathlib import Path
from datetime import UTC, datetime
import json


class SparkWorkspace:

    def __init__(self, root):

        self.root = Path(root)

        self.workspace = (
            self.root /
            "Crystal/us/workspace"
        )

        self.evidence = (
            self.root /
            "Crystal/us/evidence"
        )


    def create(self):

        paths = [
            self.workspace / "shared",
            self.workspace / "matthew",
            self.workspace / "taylor",
        ]

        for path in paths:
            path.mkdir(
                parents=True,
                exist_ok=True,
            )


        artifact = {
            "component": "spark-workspace-foundation",
            "version": "0.1",
            "timestamp": datetime.now(UTC).isoformat(),
            "workspace": str(self.workspace),
            "participants": [
                "matthew",
                "taylor",
            ],
            "shared": True,
            "status": "CREATED",
        }


        evidence = (
            self.evidence /
            "spark-workspace-certification.json"
        )

        evidence.write_text(
            json.dumps(
                artifact,
                indent=2,
            )
        )


        return artifact
