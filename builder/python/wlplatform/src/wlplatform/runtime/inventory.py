import json
from pathlib import Path


class RuntimeInventory:

    def __init__(self, root):

        self.path = (
            Path(root)
            / "capabilities/runtime/config/runtimes.json"
        )


    def load(self):

        if not self.path.exists():
            return []

        data = json.loads(
            self.path.read_text()
        )

        return data.get(
            "runtimes",
            []
        )
