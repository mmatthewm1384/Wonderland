from pathlib import Path
import json


class RegistryValidationService:
    """
    Validates the auto-drop registry.

    Registry authority:
        manifest.json

    Directories without manifests are not packages.
    """

    def __init__(self, root):
        self.root = Path(root)

    def validate(self):
        malformed = self.malformed_manifests()
        duplicates = self.duplicate_package_ids()
        missing = self.missing_manifests()

        return {
            "passed": not any(
                [
                    malformed,
                    duplicates,
                    missing,
                ]
            ),
            "malformed_manifests": malformed,
            "duplicate_package_ids": duplicates,
            "missing_manifests": missing,
        }

    def package_root(self):
        return (
            self.root
            / "scripts"
            / "auto-drop"
            / "packages"
        )

    def manifest_files(self):
        root = self.package_root()

        if not root.exists():
            return []

        return sorted(
            root.glob("*/manifest.json")
        )

    def malformed_manifests(self):
        malformed = []

        for manifest in self.manifest_files():
            try:
                data = json.loads(
                    manifest.read_text()
                )

                if not isinstance(data, dict):
                    malformed.append(
                        str(manifest)
                    )

            except Exception:
                malformed.append(
                    str(manifest)
                )

        return sorted(malformed)

    def duplicate_package_ids(self):
        package_ids = []
        duplicates = []

        for manifest in self.manifest_files():
            try:
                data = json.loads(
                    manifest.read_text()
                )

                package_id = (
                    data.get("package")
                    or manifest.parent.name
                )

                if package_id in package_ids:
                    duplicates.append(
                        package_id
                    )

                package_ids.append(
                    package_id
                )

            except Exception:
                continue

        return sorted(
            set(duplicates)
        )

    def expected_packages(self):
        """
        Required foundation packages.

        Filesystem directories are not authority.
        """

        return [
            "trust-foundation-v1",
            "identity-foundation-v1",
            "runtime-foundation-v1",
        ]

    def missing_manifests(self):
        """
        A package exists only when manifest.json exists.
    
        Registry discovery is manifest-driven.
    
        Directories without manifests are ignored:
            artifacts/
            evidence/
            docs/
            lifecycle/
            governance/
            tests/
    
        Required package policy belongs to certification,
        not registry validation.
        """
    
        missing = []
    
        package_root = self.package_root()
    
        if not package_root.exists():
            return missing
    
        for package_dir in package_root.iterdir():
            if not package_dir.is_dir():
                continue
    
            manifest = package_dir / "manifest.json"
    
            # Non-manifest directories are not packages.
            if not manifest.exists():
                continue
    
            try:
                json.loads(
                    manifest.read_text()
                )
    
            except Exception:
                continue
    
        return sorted(missing)
