from pathlib import Path
import json
from datetime import datetime, timezone

DEFAULT_STATE = {
    "version": "1.0.0",
    "state": "ACTIVE",
    "previous_state": None,
    "certified": True,
    "updated_at": None
}


class EcologyStore:

    def __init__(self, wl_root):

        self.path = (
            Path(wl_root)
            / "vault"
            / "08-Operations"
            / "runtime"
            / "ecology.json"
        )

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True
        )

    def load(self):

        if not self.path.exists():
            self.save(DEFAULT_STATE.copy())

        return json.loads(
            self.path.read_text()
        )

    def save(self, data):

        data["updated_at"] = (
            datetime.now(
                timezone.utc
            ).isoformat()
        )

        self.path.write_text(
            json.dumps(
                data,
                indent=2
            )
        )
