from pathlib import Path
import json


class CapabilityPolicy:

    def __init__(self, root):
        self.root = Path(root)

        self.policy_path = (
            self.root
            / "vault"
            / "05-Registry"
            / "capabilities.json"
        )

    def load(self):

        if not self.policy_path.exists():
            return {
                "schema_version": 1,
                "capabilities": {}
            }

        return json.loads(
            self.policy_path.read_text()
        )

    def allowed(self, package, capability):

        policy = self.load()

        package_caps = (
            policy
            .get("capabilities", {})
            .get(package, [])
        )

        return capability in package_caps
