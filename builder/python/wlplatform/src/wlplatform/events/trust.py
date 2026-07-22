"""
Wonderland Trust Attestation Ledger.
"""

from pathlib import Path
import json


class TrustLedger:

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
        attestation: dict
    ):

        with self.path.open(
            "a",
            encoding="utf-8"
        ) as file:

            file.write(
                json.dumps(
                    attestation
                )
                + "\n"
            )
