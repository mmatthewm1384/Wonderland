#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

echo "=============================================="
echo "Certification Evidence Digest v1.1"
echo "=============================================="


CERT_ROOT="vault/08-Operations/certifications/certification-engine-1.1"

mkdir -p "$CERT_ROOT"


MANIFEST="$CERT_ROOT/evidence-digest.json"


echo "Generating evidence digest manifest..."

python3 <<'PYTHON'
from pathlib import Path
import hashlib
import json
from datetime import datetime, timezone


root = Path(
    "vault/08-Operations/certifications/"
    "certification-engine-1.1"
)

manifest = {
    "engine": "certification",
    "version": "1.1",
    "generated": datetime.now(
        timezone.utc
    ).isoformat(),
    "algorithm": "sha256",
    "files": []
}


for path in sorted(root.rglob("*")):
    if (
        path.is_file()
        and path.name != "evidence-digest.json"
    ):
        digest = hashlib.sha256(
            path.read_bytes()
        ).hexdigest()

        manifest["files"].append(
            {
                "path": str(
                    path.relative_to(root)
                ),
                "sha256": digest
            }
        )


(root / "evidence-digest.json").write_text(
    json.dumps(
        manifest,
        indent=2
    )
)

print(
    f"Digest entries: {len(manifest['files'])}"
)

PYTHON


TEST_FILE="builder/python/wlplatform/tests/test_certification_digest.py"


cat > "$TEST_FILE" <<'PYTEST'
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
PYTEST


echo
echo "Running digest verification..."

python3 -m pytest \
"$TEST_FILE" \
-v


echo
echo "Certification Evidence Digest PASS"
