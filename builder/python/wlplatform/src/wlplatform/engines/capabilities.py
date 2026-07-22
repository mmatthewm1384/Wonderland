from __future__ import annotations

import json
from pathlib import Path


class CapabilityRegistry:

    def __init__(self, root: Path):
        self.root = Path(root)

        self.path = (
            self.root
            /
            "vault/05-Registry/engines/capabilities.json"
        )

    def load(self):

        if not self.path.exists():
            return {}

        payload = json.loads(
            self.path.read_text()
        )

        return payload.get(
            "capabilities",
            {}
        )


    def owner(self, capability: str):

        registry = self.load()

        entry = registry.get(capability)

        if entry is None:
            raise ValueError(
                f"Unknown capability: {capability}"
            )

        return entry["owner"]


# ---------------------------------------------------------
# Compatibility API
# Engine Registry v1.4
# Artifact-backed adapters
# ---------------------------------------------------------


def list_capabilities(root):

    registry = CapabilityRegistry(root)

    return registry.load()



def capability_owner(root, capability):

    registry = CapabilityRegistry(root)

    return registry.owner(capability)



def get_capability(root, capability):

    registry = CapabilityRegistry(root)

    data = registry.load()

    return data.get(capability)

