from pathlib import Path
import json
import re


class CapabilityPolicyValidator:
    """
    Validates registry capability authorization policy.

    Authority:

        vault/05-Registry/capabilities.json

    Rules:

        - policy must be valid JSON
        - package references must exist
        - capability names must be valid
        - grants cannot be empty
    """

    CAPABILITY_PATTERN = re.compile(
        r"^[a-z0-9_.-]+$"
    )

    def __init__(self, root):
        self.root = Path(root)

        self.policy_path = (
            self.root
            / "vault"
            / "05-Registry"
            / "capabilities.json"
        )

        self.packages_root = (
            self.root
            / "scripts"
            / "auto-drop"
            / "packages"
        )

    def validate(self):

        return {
            "passed":
                not any(
                    [
                        self.malformed_policy(),
                        self.unknown_packages(),
                        self.invalid_capabilities(),
                        self.empty_grants(),
                    ]
                ),
            "malformed_policy":
                self.malformed_policy(),
            "unknown_packages":
                self.unknown_packages(),
            "invalid_capabilities":
                self.invalid_capabilities(),
            "empty_grants":
                self.empty_grants(),
        }

    def load_policy(self):

        if not self.policy_path.exists():
            return {}

        try:
            return json.loads(
                self.policy_path.read_text()
            )

        except Exception:
            return None

    def malformed_policy(self):

        data = self.load_policy()

        if data is None:
            return [
                str(self.policy_path)
            ]

        if not isinstance(data, dict):
            return [
                "root"
            ]

        if not isinstance(
            data.get("capabilities"),
            dict,
        ):
            return [
                "capabilities"
            ]

        return []

    def unknown_packages(self):

        data = self.load_policy()

        if not data:
            return []

        unknown = []

        for package in (
            data.get(
                "capabilities",
                {},
            )
        ):

            manifest = (
                self.packages_root
                / package
                / "manifest.json"
            )

            if not manifest.exists():
                unknown.append(package)

        return sorted(unknown)

    def invalid_capabilities(self):

        data = self.load_policy()

        if not data:
            return []

        invalid = []

        for package, capabilities in (
            data.get(
                "capabilities",
                {},
            ).items()
        ):

            if not isinstance(
                capabilities,
                list,
            ):
                invalid.append(package)
                continue

            for capability in capabilities:

                if (
                    not isinstance(
                        capability,
                        str,
                    )
                    or not self.CAPABILITY_PATTERN.match(
                        capability
                    )
                ):
                    invalid.append(
                        f"{package}:{capability}"
                    )

        return sorted(invalid)

    def empty_grants(self):

        data = self.load_policy()

        if not data:
            return []

        empty = []

        for package, capabilities in (
            data.get(
                "capabilities",
                {},
            ).items()
        ):

            if capabilities == []:
                empty.append(package)

        return sorted(empty)
