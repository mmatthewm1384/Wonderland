from pathlib import Path
import hashlib
import json
from datetime import datetime, timezone

from wlplatform.registry.capability_graph_validation import (
    CapabilityGraphValidator,
)
from wlplatform.registry.capability_validation import (
    CapabilityPolicyValidator,
)
from wlplatform.registry.validation import (
    RegistryValidationService,
)


class RegistryCertification:
    """
    Certifies registry trust readiness.

    Certification chain:

        manifests
            |
            v
        validation
            |
            v
        foundation verification
            |
            v
        evidence generation
            |
            v
        integrity hashes
    """

    def __init__(self, root):
        self.root = Path(root)

        self.registry_index = (
            self.root
            / "vault"
            / "05-Registry"
            / "auto-drop"
            / "package-index.json"
        )

        self.package_root = (
            self.root
            / "scripts"
            / "auto-drop"
            / "packages"
        )

        self.evidence_dir = (
            self.root
            / "vault"
            / "08-Operations"
            / "evidence"
            / "registry-certification"
        )

    def required_foundations(self):
        return [
            "trust-foundation-v1",
            "identity-foundation-v1",
            "runtime-foundation-v1",
        ]

    def installed_packages(self):
        packages = set()

        if not self.package_root.exists():
            return packages

        for manifest in self.package_root.glob(
            "*/manifest.json"
        ):
            try:
                data = json.loads(
                    manifest.read_text()
                )

                package_id = (
                    data.get("package")
                    or data.get("name")
                    or manifest.parent.name
                )

                packages.add(
                    package_id
                )

            except Exception:
                continue

        return packages

    def verify_foundations(self):
        return sorted(
            set(
                self.required_foundations()
            )
            -
            self.installed_packages()
        )

    def sha256_file(self, path):
        digest = hashlib.sha256()

        with path.open("rb") as file:
            for chunk in iter(
                lambda: file.read(65536),
                b"",
            ):
                digest.update(chunk)

        return digest.hexdigest()

    def manifest_digests(self):
        digests = {}

        if not self.package_root.exists():
            return digests

        for manifest in sorted(
            self.package_root.glob(
                "*/manifest.json"
            )
        ):
            package_id = (
                manifest.parent.name
            )

            digests[package_id] = (
                "sha256:"
                +
                self.sha256_file(
                    manifest
                )
            )

        return digests

    def write_evidence(
        self,
        result,
    ):
        self.evidence_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

        manifest_hashes = (
            self.manifest_digests()
        )

        manifest_path = (
            self.evidence_dir
            / "manifest-digests.json"
        )

        manifest_path.write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "generated":
                        datetime.now(
                            timezone.utc
                        ).isoformat(),
                    "manifests":
                        manifest_hashes,
                },
                indent=2,
                sort_keys=True,
            )
            + "\n"
        )

        certificate = {
            "schema_version": 1,
            "type":
                "registry-certification",
            "generated":
                datetime.now(
                    timezone.utc
                ).isoformat(),
            **result,
            "registry_index_sha256":
                (
                    "sha256:"
                    +
                    self.sha256_file(
                        self.registry_index
                    )
                ),
            "manifest_digest_file":
                str(
                    manifest_path.relative_to(
                        self.root
                    )
                ),
        }

        certificate_path = (
            self.evidence_dir
            / "latest.json"
        )

        certificate_path.write_text(
            json.dumps(
                certificate,
                indent=2,
                sort_keys=True,
            )
            + "\n"
        )

        certificate_hash = (
            self.sha256_file(
                certificate_path
            )
        )

        (
            self.evidence_dir
            / "latest.sha256"
        ).write_text(
            "sha256:"
            + certificate_hash
            + "\n"
        )

        return str(
            certificate_path.relative_to(
                self.root
            )
        )

    def certify(self):

        if not self.registry_index.exists():
            raise RuntimeError(
                "Registry index missing"
            )

        index = json.loads(
            self.registry_index.read_text()
        )

        validation = RegistryValidationService(
            self.root
        ).validate()

        if not validation["passed"]:
            raise RuntimeError(
                json.dumps(
                    {
                        "error":
                            "Registry validation failed",
                        **validation,
                    },
                    indent=2,
                )
            )

        capability_validation = (
            CapabilityPolicyValidator(
                self.root
            ).validate()
        )
        
        if not capability_validation["passed"]:
            raise RuntimeError(
                json.dumps(
                    {
                        "error":
                            "Capability policy validation failed",
                        **capability_validation,
                    },
                    indent=2,
                )
            )

        capability_graph = (
            CapabilityGraphValidator(
                self.root
            ).validate()
        )
        
        if not capability_graph["passed"]:
            raise RuntimeError(
                json.dumps(
                    {
                        "error":
                            "Capability graph validation failed",
                        **capability_graph,
                    },
                    indent=2,
                )
            )

        missing_foundations = (
            self.verify_foundations()
        )

        if missing_foundations:
            raise RuntimeError(
                json.dumps(
                    {
                        "error":
                            "Registry foundation requirements failed",
                        "missing_foundations":
                            missing_foundations,
                    },
                    indent=2,
                )
            )

        result = {
            "status":
                "CERTIFIED",
            "foundations":
                self.required_foundations(),
            "packages":
                len(
                    index.get(
                        "packages",
                        {},
                    )
                ),
        }

        result["certificate"] = (
            self.write_evidence(
                result
            )
        )

        return result
