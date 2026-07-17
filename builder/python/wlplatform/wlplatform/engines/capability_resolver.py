from __future__ import annotations

import json
from pathlib import Path


class CapabilityResolver:

    def __init__(self, root: Path):

        self.root = Path(root)

        self.registry = (
            self.root
            / "vault/05-Registry/engines/capabilities.json"
        )

        payload = json.loads(
            self.registry.read_text()
        )

        self.schema_version = payload.get(
            "schema_version",
            1,
        )

        self.owners = payload.get(
            "owners",
            {},
        )

    def owner(
        self,
        capability: str,
    ) -> str:

        owner = self.owners.get(
            capability,
        )

        if owner is None:

            raise ValueError(
                f"Unknown capability: {capability}"
            )

        return owner

    def capabilities(self):

        return sorted(
            self.owners.keys()
        )
