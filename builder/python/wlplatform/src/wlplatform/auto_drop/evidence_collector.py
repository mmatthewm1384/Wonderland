#!/usr/bin/env python3

from pathlib import Path
from datetime import datetime, timezone
import json


class EvidenceCollector:


    def __init__(self, root=None):

        self.root = (
            Path(root)
            if root
            else self.find_root()
        )

        self.evidence_dir = (
            self.root /
            "vault/08-Operations/evidence/auto-drop"
        )

        self.evidence_dir.mkdir(
            parents=True,
            exist_ok=True
        )


    def find_root(self):

        path = Path(__file__).resolve()

        for parent in path.parents:

            if (
                parent.name == "Wonderland"
                and (parent / "vault").exists()
            ):
                return parent

        raise RuntimeError(
            "Wonderland root not found"
        )


    def write(
        self,
        artifact,
        version,
        validation,
        certification,
        rollback,
        transaction_id
    ):

        timestamp = datetime.now(
            timezone.utc
        ).isoformat()

        evidence = {
            "transaction_id": transaction_id,
            "artifact": artifact,
            "version": version,
            "validation": validation,
            "certification": certification,
            "rollback": rollback,
            "timestamp": timestamp
        }


        filename = (
            f"{artifact.replace('/', '_')}-"
            f"{transaction_id}.json"
        )

        path = (
            self.evidence_dir /
            filename
        )

        path.write_text(
            json.dumps(
                evidence,
                indent=2
            )
        )

        return path


if __name__ == "__main__":

    collector = EvidenceCollector()

    result = collector.write(
        artifact="test/example",
        version="1.0.0",
        validation="PASS",
        certification="PASS",
        rollback="PASS",
        transaction_id="test"
    )

    print(result)
