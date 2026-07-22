"""
Wonderland Evidence Ledger.
"""

from pathlib import Path
import json


class EvidenceLedger:

    def __init__(
        self,
        path
    ):

        self.path = Path(path)

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True
        )


    def append(
        self,
        evidence: dict
    ):

        with self.path.open(
            "a",
            encoding="utf-8"
        ) as file:

            file.write(
                json.dumps(
                    evidence
                )
                + "\n"
            )


    def replay(self):

        if not self.path.exists():
            return []

        with self.path.open(
            encoding="utf-8"
        ) as file:

            return [
                json.loads(line)
                for line in file
            ]
