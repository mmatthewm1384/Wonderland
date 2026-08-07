from pathlib import Path
from datetime import datetime, timezone
import json


class EvidenceWriter:


    def __init__(self, root):

        self.path = (
            Path(root)
            /
            "Evidence"
            /
            "genesis-cli"
        )

        self.path.mkdir(
            parents=True,
            exist_ok=True
        )


    def write(self, data):

        file = (
            self.path
            /
            "latest.json"
        )

        file.write_text(
            json.dumps(
                {
                    "timestamp":
                    datetime.now(timezone.utc).isoformat(),

                    "result":
                    data
                },
                indent=2
            )
        )
