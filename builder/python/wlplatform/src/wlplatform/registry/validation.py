import json


class RegistryValidationService:

    def __init__(self, root):

        self.root = root

        self.packages_root = (
            self.root /
            "scripts/auto-drop/packages"
        )


    def validate(self):

        return {
            "passed":
                not any(
                    [
                        self.malformed_manifests(),
                        self.duplicate_package_ids(),
                        self.missing_manifests(),
                    ]
                ),

            "malformed_manifests":
                self.malformed_manifests(),

            "duplicate_package_ids":
                self.duplicate_package_ids(),

            "missing_manifests":
                self.missing_manifests(),
        }


    def manifests(self):

        result = []

        if not self.packages_root.exists():

            return result

        for package in sorted(
            self.packages_root.iterdir()
        ):

            manifest = (
                package /
                "manifest.json"
            )

            result.append(
                (
                    package.name,
                    manifest
                )
            )

        return result


    def malformed_manifests(self):

        failures = []

        for name, manifest in self.manifests():

            if not manifest.exists():

                continue

            try:

                json.loads(
                    manifest.read_text()
                )

            except Exception:

                failures.append(name)

        return failures


    def duplicate_package_ids(self):

        seen = set()
        duplicates = []

        for name, manifest in self.manifests():

            if not manifest.exists():

                continue

            data = json.loads(
                manifest.read_text()
            )

            package_id = (
                data.get(
                    "name",
                    name
                )
            )

            if package_id in seen:

                duplicates.append(
                    package_id
                )

            seen.add(
                package_id
            )

        return duplicates


    def missing_manifests(self):

        registry_packages = (
            self.root /
            "vault" /
            "05-Registry" /
            "auto-drop" /
            "package-index.json"
        )

        if not registry_packages.exists():

            return []


        import json

        data = json.loads(
            registry_packages.read_text()
        )

        missing = []


        for package in data.get(
            "packages",
            {}
        ):

            manifest = (
                self.packages_root /
                package /
                "manifest.json"
            )

            if not manifest.exists():

                missing.append(
                    package
                )


        return missing
