"""
Certification Engine Finalization Verification
"""

import json
from pathlib import Path


ROOT = Path(
    "vault/08-Operations/certifications/"
    "certification-engine-1.1"
)


def test_certification_report_exists():

    report = ROOT / "certification-report.json"

    assert report.exists()


def test_certification_status():

    report = ROOT / "certification-report.json"

    data = json.loads(
        report.read_text()
    )

    assert data["status"] == "CERTIFIED"


def test_required_artifacts_present():

    report = ROOT / "certification-report.json"

    data = json.loads(
        report.read_text()
    )

    for artifact in data["artifacts"]:
        assert (
            ROOT / artifact
        ).exists()


def test_all_verification_states_pass():

    report = ROOT / "certification-report.json"

    data = json.loads(
        report.read_text()
    )

    for state in data["verification"].values():
        assert state == "PASS"
