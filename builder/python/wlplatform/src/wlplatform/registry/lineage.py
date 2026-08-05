from pathlib import Path
import hashlib
import json
from datetime import datetime, timezone


class RegistryLineage:

    def __init__(self, root):

        self.root = Path(root)

        self.packages_root = (
            self.root /
            "scripts/auto-drop/packages"
        )


    def sha256(self, path):

        digest = hashlib.sha256()

        digest.update(
            path.read_bytes()
        )

        return digest.hexdigest()


    def manifest_hashes(self):

        result = {}

        if not self.packages_root.exists():

            return result


        for package in sorted(
            self.packages_root.iterdir()
        ):

            manifest = (
                package /
                "manifest.json"
            )

            if manifest.exists():

                result[package.name] = {
                    "path":
                        str(
                            manifest.relative_to(
                                self.root
                            )
                        ),

                    "sha256":
                        self.sha256(
                            manifest
                        )
                }


        return result


    def registry_hash(self):

        registry = (
            self.root /
            "vault" /
            "05-Registry" /
            "auto-drop" /
            "package-index.json"
        )

        if not registry.exists():

            return None


        return self.sha256(
            registry
        )


    def create(self, verification):

        return {
            "schema_version": 1,

            "artifact":
                "auto-drop-registry-lineage",

            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat(),

            "manifests":
                self.manifest_hashes(),

            "registry_sha256":
                self.registry_hash(),

            "verification":
                verification
        }
