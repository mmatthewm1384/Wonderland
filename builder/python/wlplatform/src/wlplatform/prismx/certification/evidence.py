"""
PRISMX Evidence Persistence
"""

import json
from pathlib import Path


class PrismEvidenceStore:


    def __init__(self, path):

        self.path = Path(path)


    def write(self, record):

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        with self.path.open("w") as file:

            json.dump(
                record.__dict__,
                file,
                indent=2
            )

        return self.path
