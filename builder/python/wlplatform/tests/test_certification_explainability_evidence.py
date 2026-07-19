"""
Evidence-backed Explainability Verification
"""

import hashlib
import json
from pathlib import Path


ROOT = Path(
    "vault/08-Operations/certifications/"
    "certification-engine-1.1"
)


def test_explainability_report_exists():

    assert (
        ROOT /
        "certification-explainability.json"
    ).exists()



def test_evidence_is_traceable():

    report = json.loads(
        (
            ROOT /
            "certification-explainability.json"
        ).read_text()
    )


    for item in report["explanation"]["evidence"]:

        artifact = (
            ROOT /
            item["path"]
        )

        assert artifact.exists()



def test_evidence_digest_matches():

    report = json.loads(
        (
            ROOT /
            "certification-explainability.json"
        ).read_text()
    )


    for item in report["explanation"]["evidence"]:

        artifact = (
            ROOT /
            item["path"]
        )

        digest = hashlib.sha256(
            artifact.read_bytes()
        ).hexdigest()


        assert digest == item["sha256"]



def test_trust_remains_certified():

    report = json.loads(
        (
            ROOT /
            "certification-explainability.json"
        ).read_text()
    )

    assert (
        report["status"]
        ==
        "CERTIFIED"
    )
