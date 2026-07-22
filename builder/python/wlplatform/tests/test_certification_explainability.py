"""
Certification Explainability Report Verification
"""

import json
from pathlib import Path


ROOT = Path(
    "vault/08-Operations/certifications/"
    "certification-engine-1.1"
)


def test_report_exists():

    report = (
        ROOT /
        "certification-explainability.json"
    )

    assert report.exists()



def test_report_certified():

    report = (
        ROOT /
        "certification-explainability.json"
    )

    data = json.loads(
        report.read_text()
    )

    assert data["status"] == "CERTIFIED"



def test_report_contains_lineage():

    report = (
        ROOT /
        "certification-explainability.json"
    )

    data = json.loads(
        report.read_text()
    )

    lineage = (
        data["explanation"]["lineage"]
    )

    assert "policy" in lineage
    assert "trust" in lineage



def test_report_contains_integrity():

    report = (
        ROOT /
        "certification-explainability.json"
    )

    data = json.loads(
        report.read_text()
    )

    assert (
        data["explanation"]
        ["integrity"]
        ["verified"]
        is True
    )
