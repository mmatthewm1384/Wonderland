from __future__ import annotations

import json
from pathlib import Path


class LifecycleRegistry:

    def __init__(self, root: Path):

        self.root = Path(root)

        self.path = (
            self.root
            /
            "vault/05-Registry/engines/lifecycle.json"
        )


    def load(self):

        if not self.path.exists():
            return {}

        payload = json.loads(
            self.path.read_text()
        )

        return payload.get(
            "lifecycle",
            {}
        )


    def resolve(self, action):

        registry = self.load()

        entry = registry.get(action)

        if entry is None:
            raise ValueError(
                f"Unknown lifecycle action: {action}"
            )

        return entry
