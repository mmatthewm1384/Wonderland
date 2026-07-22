"""
Wonderland Event Observability Recorder.
"""

from pathlib import Path
import json


class ObservabilityRecorder:

    def __init__(
        self,
        path
    ):
        self.path = Path(path)

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True
        )


    def record(
        self,
        observation: dict
    ):

        with self.path.open(
            "a",
            encoding="utf-8"
        ) as file:

            file.write(
                json.dumps(
                    observation
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
