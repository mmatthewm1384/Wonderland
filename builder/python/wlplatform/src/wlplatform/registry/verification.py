from pathlib import Path
import hashlib
import json


class RegistryVerification:
    """
    Verifies registry certification evidence.

    Verification chain:

        latest.json
            |
            +--> certificate hash
            |
            +--> registry index hash
            |
            +--> manifest digest validation
            |
            v
        TRUST VERIFIED
    """

    def __init__(self, root):
        self.root = Path(root)

        self.evidence_dir = (
            self.root
            / "vault"
            / "08-Operations"
            / "evidence"
            / "registry-certification"
        )

        self.certificate = (
            self.evidence_dir
            / "latest.json"
        )

        self.certificate_hash = (
            self.evidence_dir
            / "latest.sha256"
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

    def verify_certificate_hash(self):
        if not self.certificate_hash.exists():
            return False

        expected = (
            self.certificate_hash
            .read_text()
            .strip()
        )

        actual = (
            "sha256:"
            +
            self.sha256_file(
                self.certificate
            )
        )

        return expected == actual

    def verify_registry_index(self, certificate):
        index = (
            self.root
            / "vault"
            / "05-Registry"
            / "auto-drop"
            / "package-index.json"
        )

        if not index.exists():
            return False

        expected = (
            certificate
            .get(
                "registry_index_sha256"
            )
        )

        actual = (
            "sha256:"
            +
            self.sha256_file(
                index
            )
        )

        return expected == actual

    def verify_manifests(self, certificate):
        digest_file = (
            self.root
            /
            certificate[
                "manifest_digest_file"
            ]
        )

        if not digest_file.exists():
            return False

        data = json.loads(
            digest_file.read_text()
        )

        expected = (
            data.get(
                "manifests",
                {}
            )
        )

        packages_root = (
            self.root
            / "scripts"
            / "auto-drop"
            / "packages"
        )

        for package, digest in expected.items():
            manifest = (
                packages_root
                / package
                / "manifest.json"
            )

            if not manifest.exists():
                return False

            actual = (
                "sha256:"
                +
                self.sha256_file(
                    manifest
                )
            )

            if actual != digest:
                return False

        return True

    def verify(self):

        if not self.certificate.exists():
            raise RuntimeError(
                "Certification evidence missing"
            )

        certificate = json.loads(
            self.certificate.read_text()
        )

        result = {
            "certificate_hash":
                self.verify_certificate_hash(),

            "registry_index":
                self.verify_registry_index(
                    certificate
                ),

            "manifests":
                self.verify_manifests(
                    certificate
                ),
        }

        result["passed"] = all(
            result.values()
        )

        result["status"] = (
            "TRUST VERIFIED"
            if result["passed"]
            else "TRUST FAILED"
        )

        return result
