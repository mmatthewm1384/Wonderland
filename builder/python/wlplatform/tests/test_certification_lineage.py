"""
Certification Lineage Verification

Ensures certification trust has complete evidence lineage.
"""

import json
from pathlib import Path


def test_certification_lineage_exists():

    root = Path(
        "vault/08-Operations/certifications/"
        "certification-engine-1.1/"
    )

    lineage = root / "lineage.json"

    assert lineage.exists()


def test_certification_lineage_complete():

    lineage = Path(
        "vault/08-Operations/certifications/"
        "certification-engine-1.1/"
        "lineage.json"
    )

    data = json.loads(lineage.read_text())


    required = [
        "policy",
        "registry",
        "engine-evidence",
        "certification",
        "trust",
    ]


    stages = [
        item["stage"]
        for item in data["lineage"]
    ]


    for stage in required:
        assert stage in stages


def test_certification_trust_state():

    lineage = Path(
        "vault/08-Operations/certifications/"
        "certification-engine-1.1/"
        "lineage.json"
    )

    data = json.loads(lineage.read_text())

    assert data["status"] == "CERTIFIED"
