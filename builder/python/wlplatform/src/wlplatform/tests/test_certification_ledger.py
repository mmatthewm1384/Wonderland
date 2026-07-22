from pathlib import Path

from wlplatform.certification_ledger import (
    CertificationLedger,
)


ROOT = Path(
    "/Users/wonderland/Wonderland"
)


def test_certification_ledger():

    ledger = CertificationLedger(
        ROOT
    )

    event = ledger.append(
        {
            "engine": "mirror",
            "action": "certify",
            "status": "PASS",
            "certified": True,
        }
    )

    assert event["engine"] == "mirror"
    assert event["status"] == "PASS"

    history = ledger.history()

    assert history
