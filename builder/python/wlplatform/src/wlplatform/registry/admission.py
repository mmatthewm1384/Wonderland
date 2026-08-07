from pathlib import Path
import json


class RegistryAdmission:

    def __init__(self, root):
        self.root = Path(root)

        self.evidence_dir = (
            self.root
            / "vault"
            / "08-Operations"
            / "evidence"
            / "registry-certification"
        )

        self.packages_root = (
            self.root
            / "scripts"
            / "auto-drop"
            / "packages"
        )

    def load_attestation(self):

        path = (
            self.evidence_dir
            / "attestation.json"
        )

        if not path.exists():
            raise RuntimeError(
                "Registry attestation missing"
            )

        return json.loads(
            path.read_text()
        )

    def load_manifest(self, package):

        manifest = (
            self.packages_root
            / package
            / "manifest.json"
        )

        if not manifest.exists():
            raise RuntimeError(
                f"Package manifest missing: {package}"
            )

        return json.loads(
            manifest.read_text()
        )

    def admit(self, package):

        attestation = (
            self.load_attestation()
        )

        manifest = (
            self.load_manifest(package)
        )

        foundations = (
            attestation.get(
                "foundations",
                []
            )
        )

        required = [
            "trust-foundation-v1",
            "identity-foundation-v1",
            "runtime-foundation-v1",
        ]

        missing = [
            item
            for item in required
            if item not in foundations
        ]

        if missing:
            raise RuntimeError(
                json.dumps(
                    {
                        "error":
                            "Foundation trust missing",
                        "missing":
                            missing,
                    },
                    indent=2,
                )
            )

        return {
            "status":
                "ADMITTED",
            "package":
                package,
            "version":
                manifest.get(
                    "version"
                ),
            "attestation":
                "valid",
            "foundations":
                foundations,
        }
