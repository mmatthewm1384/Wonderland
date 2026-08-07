from pathlib import Path
import json


class CapabilityRegistry:

    def __init__(self, root):
        self.root = Path(root)

        self.index = (
            self.root
            / "vault"
            / "05-Registry"
            / "auto-drop"
            / "capability-index.json"
        )

    def load(self):
        if not self.index.exists():
            raise RuntimeError(
                "Capability registry missing"
            )

        return json.loads(
            self.index.read_text()
        )

    def authorized(self, package, capability):
        data = self.load()

        entry = (
            data
            .get("capabilities", {})
            .get(capability)
        )

        if entry is None:
            return False

        return (
            package
            in entry.get(
                "authorized_packages",
                [],
            )
        )
