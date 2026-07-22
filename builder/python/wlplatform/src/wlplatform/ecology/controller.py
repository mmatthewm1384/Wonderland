import json
from pathlib import Path

from .transitions import TRANSITIONS


STATE_FILE = Path(
    "vault/08-Operations/runtime/ecology-state.json"
)


class EcologyController:

    def __init__(self):
        self.state = self.load()

    def load(self):

        if STATE_FILE.exists():
            return json.loads(
                STATE_FILE.read_text()
            )

        return {
            "state": "ACTIVE",
            "certified": False
        }


    def transition(self, target):

        current = self.state["state"]

        if target not in TRANSITIONS[current]:
            raise RuntimeError(
                f"Invalid transition {current}->{target}"
            )

        self.state = {
            "state": target,
            "certified": True
        }

        STATE_FILE.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        STATE_FILE.write_text(
            json.dumps(
                self.state,
                indent=2
            )
        )

        return self.state
