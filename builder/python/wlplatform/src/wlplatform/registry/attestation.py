from pathlib import Path
import hashlib
import json
from datetime import datetime, timezone


class RegistryAttestation:

    def __init__(self, root):
        self.root = Path(root)

        self.evidence_dir = (
            self.root
            / "vault"
            / "08-Operations"
            / "evidence"
            / "registry-certification"
        )

    def sha256_file(self, path):
        digest = hashlib.sha256(
            path.read_bytes()
        ).hexdigest()

        return f"sha256:{digest}"

    def manifest_tree_digest(self):
        manifests = sorted(
            (
                self.root
                / "scripts"
                / "auto-drop"
                / "packages"
            ).glob(
                "*/manifest.json"
            )
        )

        digest = hashlib.sha256()

        for manifest in manifests:
            digest.update(
                str(
                    manifest.relative_to(
                        self.root
                    )
                ).encode()
            )

            digest.update(
                manifest.read_bytes()
            )

        return f"sha256:{digest.hexdigest()}"

    def package_count(self):
        return len(
            list(
                (
                    self.root
                    / "scripts"
                    / "auto-drop"
                    / "packages"
                ).glob(
                    "*/manifest.json"
                )
            )
        )

    def generate(self):

        certificate = (
            self.evidence_dir
            / "latest.json"
        )

        if not certificate.exists():
            raise RuntimeError(
                "Registry certificate missing"
            )

        certificate_data = json.loads(
            certificate.read_text()
        )

        attestation = {
            "type":
                "registry-attestation",
            "schema_version":
                1,
            "registry_certificate":
                str(
                    certificate.relative_to(
                        self.root
                    )
                ),
            "registry_certificate_sha256":
                self.sha256_file(
                    certificate
                ),
            "registry_index_sha256":
                certificate_data.get(
                    "registry_index_sha256"
                ),
            "manifest_tree_sha256":
                self.manifest_tree_digest(),
            "package_count":
                self.package_count(),
            "foundations":
                certificate_data.get(
                    "foundations",
                    [],
                ),
            "generated":
                datetime.now(
                    timezone.utc
                ).isoformat(),
        }

        output = (
            self.evidence_dir
            / "attestation.json"
        )

        output.write_text(
            json.dumps(
                attestation,
                indent=2,
            )
        )

        return {
            "status":
                "ATTESTED",
            "attestation":
                str(
                    output.relative_to(
                        self.root
                    )
                ),
            "packages":
                attestation[
                    "package_count"
                ],
            "manifest_tree_sha256":
                attestation[
                    "manifest_tree_sha256"
                ],
        }
