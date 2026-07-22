from pathlib import Path
from wlplatform.evidence.transaction import (
    EvidenceTransaction
)


def test_commit(tmp_path):

    tx = EvidenceTransaction(
        tmp_path
    )

    result = tx.commit(
        "test-engine",
        "PASS"
    )

    assert result["digest"]

    entries = list(
        (tmp_path / "entries").glob(
            "*.json"
        )
    )

    assert len(entries) == 1
