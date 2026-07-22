import json
from pathlib import Path

from .entry import AuditEntry


class AuditChain:


    def __init__(self, path):

        self.path = Path(path)

        if not self.path.exists():

            self.path.write_text(
                json.dumps([])
            )


    def append(self, entry):

        entries = json.loads(
            self.path.read_text()
        )

        if entries:

            entry.previous_hash = (
                entries[-1]["hash"]
            )


        record = {
            **entry.__dict__,
            "hash": entry.generate_hash()
        }

        entries.append(record)

        self.path.write_text(
            json.dumps(
                entries,
                indent=2
            )
        )

        return record


    def verify(self):

        entries = json.loads(
            self.path.read_text()
        )

        previous = ""

        for entry in entries:

            if entry["previous_hash"] != previous:

                return False

            previous = entry["hash"]

        return True
