import json
from pathlib import Path


class LifecycleLedger:


    def __init__(self, path):

        self.path = Path(path)

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True
        )


    def append(self, event):

        records = []

        if self.path.exists():

            records = json.loads(
                self.path.read_text()
            )


        records.append(
            event.serialize()
        )


        self.path.write_text(
            json.dumps(
                records,
                indent=2
            )
        )


    def read(self):

        if not self.path.exists():

            return []

        return json.loads(
            self.path.read_text()
        )
