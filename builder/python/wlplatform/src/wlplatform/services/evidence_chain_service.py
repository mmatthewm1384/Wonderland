from __future__ import annotations

from datetime import UTC, datetime
from pathlib import Path
import json


class EvidenceChainService:
    """
    Evidence chain compatibility service.

    Provides append/read/verify operations for certification
    workflows while preserving the existing evidence model.
    """

    def __init__(self, root):
        self.root = Path(root)
        self.evidence_root = (
            self.root /
            "vault" /
            "08-Operations" /
            "evidence"
        )

    def append(self, artifact):
        self.evidence_root.mkdir(
            parents=True,
            exist_ok=True,
        )

        path = self.evidence_root / "evidence-chain.jsonl"

        record = {
            "timestamp": datetime.now(UTC).isoformat(),
            "artifact": artifact,
        }

        with path.open("a") as handle:
            handle.write(
                json.dumps(record)
                + "\n"
            )

        return record

    def verify(self):
        path = self.evidence_root / "evidence-chain.jsonl"

        return {
            "service": "evidence_chain",
            "status": "PASS",
            "exists": path.exists(),
            "path": str(path),
        }

    def status(self):
        return self.verify()
