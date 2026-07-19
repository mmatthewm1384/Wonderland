"""
Certification Evidence Digest Verification
"""

import hashlib
import json
from pathlib import Path


ROOT = Path(
    "vault/08-Operations/certifications/"
    "certification-engine-1.1"
)


def test_digest_manifest_exists():

    manifest = ROOT / "evidence-digest.json"

    assert manifest.exists()


def test_digest_manifest_algorithm():

    manifest = ROOT / "evidence-digest.json"

    data = json.loads(
        manifest.read_text()
    )

    assert data["algorithm"] == "sha256"


def test_digest_integrity():

    manifest = ROOT / "evidence-digest.json"

    data = json.loads(
        manifest.read_text()
    )


    for item in data["files"]:

        file_path = (
            ROOT /
            item["path"]
        )

        assert file_path.exists()


        digest = hashlib.sha256(
            file_path.read_bytes()
        ).hexdigest()


        assert digest == item["sha256"]
