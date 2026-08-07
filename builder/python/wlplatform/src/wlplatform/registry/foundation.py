from pathlib import Path


class FoundationValidationService:
    """
    Validates required Wonderland platform foundations.

    This is a governance concern, not registry integrity.

    Registry:
        "Are manifests valid?"

    Foundation:
        "Does this platform contain required capabilities?"
    """

    REQUIRED_FOUNDATIONS = [
        "trust-foundation-v1",
        "identity-foundation-v1",
        "runtime-foundation-v1",
    ]

    def __init__(self, root):
        self.root = Path(root)

    def package_root(self):
        return (
            self.root
            / "scripts"
            / "auto-drop"
            / "packages"
        )

    def missing_foundations(self):
        missing = []

        for foundation in self.REQUIRED_FOUNDATIONS:
            manifest = (
                self.package_root()
                / foundation
                / "manifest.json"
            )

            if not manifest.exists():
                missing.append(foundation)

        return sorted(missing)

    def validate(self):
        missing = self.missing_foundations()

        return {
            "passed": not missing,
            "missing_foundations": missing,
        }
