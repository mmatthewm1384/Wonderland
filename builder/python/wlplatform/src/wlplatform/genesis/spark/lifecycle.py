from pathlib import Path
from datetime import datetime, timezone
import json


class SparkLifecycle:

    VALID_STATES = [
        "defined",
        "created",
        "running",
        "stopped",
        "snapshot",
        "destroyed"
    ]

    def __init__(self, root):
        self.root = Path(root)
        self.spark_root = self.root / "Sparks"

    def spark_path(self, name):
        return self.spark_root / name

    def state_path(self, name):
        return self.spark_path(name) / "state.json"

    def set_state(self, name, state):

        if state not in self.VALID_STATES:
            raise ValueError(
                f"Invalid state: {state}"
            )

        path = self.spark_path(name)
        path.mkdir(
            parents=True,
            exist_ok=True
        )

        data = {
            "spark": name,
            "state": state,
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat()
        }

        self.state_path(name).write_text(
            json.dumps(
                data,
                indent=2
            )
        )

        return data


    def get_state(self, name):

        state = self.state_path(name)

        if not state.exists():
            return {
                "spark": name,
                "state": "undefined"
            }

        return json.loads(
            state.read_text()
        )
