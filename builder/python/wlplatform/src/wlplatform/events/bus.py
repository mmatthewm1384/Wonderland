"""
Wonderland Event Bus.

Append-only local event transport.
"""

from pathlib import Path
import json


class EventBus:

    def __init__(self, ledger_path):

        self.path = Path(
            ledger_path
        )

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )


    def publish(self, event):

        with self.path.open(
            "a",
            encoding="utf-8",
        ) as file:

            file.write(
                json.dumps(
                    event.to_dict()
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
