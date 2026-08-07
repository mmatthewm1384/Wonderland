from pathlib import Path
import json


class CapabilityGraphValidator:
    """
    Validates capability relationships.

    Sources:

        manifest.json
            provides / requires

        capabilities.json
            grants

    """

    def __init__(self, root):
        self.root = Path(root)

        self.packages_root = (
            self.root
            / "scripts"
            / "auto-drop"
            / "packages"
        )

        self.policy_path = (
            self.root
            / "vault"
            / "05-Registry"
            / "capabilities.json"
        )

    def validate(self):

        return {
            "passed":
                not any(
                    [
                        self.unknown_packages(),
                        self.missing_providers(),
                        self.missing_requirements(),
                    ]
                ),

            "unknown_packages":
                self.unknown_packages(),

            "missing_providers":
                self.missing_providers(),

            "missing_requirements":
                self.missing_requirements(),
        }

    def manifests(self):

        results = {}

        if not self.packages_root.exists():
            return results

        for manifest in self.packages_root.glob(
            "*/manifest.json"
        ):
            try:
                data = json.loads(
                    manifest.read_text()
                )

                results[
                    manifest.parent.name
                ] = data

            except Exception:
                continue

        return results

    def policy(self):

        if not self.policy_path.exists():
            return {}

        try:
            return json.loads(
                self.policy_path.read_text()
            )

        except Exception:
            return {}

    def providers(self):

        result = {}

        for package, manifest in (
            self.manifests().items()
        ):

            for capability in (
                manifest.get(
                    "provides",
                    [],
                )
            ):
                result.setdefault(
                    capability,
                    [],
                ).append(package)

        return result

    def graph(self):
        providers = self.providers()

        consumers = {}

        for package, manifest in self.manifests().items():

            for capability in (
                manifest.get(
                    "requires",
                    [],
                )
            ):
                consumers.setdefault(
                    capability,
                    [],
                ).append(package)

        return {
            "providers": providers,
            "consumers": consumers,
            "validation": self.validate(),
        }

    def unknown_packages(self):

        policy = self.policy()

        known = set(
            self.manifests()
        )

        unknown = []

        for package in (
            policy.get(
                "capabilities",
                {},
            )
        ):

            if package not in known:
                unknown.append(package)

        return sorted(unknown)

    def missing_providers(self):

        policy = self.policy()

        available = self.providers()

        missing = []

        for package, capabilities in (
            policy.get(
                "capabilities",
                {},
            ).items()
        ):

            for capability in capabilities:

                if capability not in available:
                    missing.append(
                        f"{package}:{capability}"
                    )

        return sorted(missing)

    def missing_requirements(self):

        available = self.providers()

        missing = []

        for package, manifest in (
            self.manifests().items()
        ):

            for capability in (
                manifest.get(
                    "requires",
                    [],
                )
            ):

                if capability not in available:
                    missing.append(
                        f"{package}:{capability}"
                    )

        return sorted(missing)
