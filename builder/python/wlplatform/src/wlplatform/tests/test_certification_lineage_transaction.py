from pathlib import Path

from wlplatform.certification_lineage import (
    persist_lineage,
)


ROOT = Path(
    "/Users/wonderland/Wonderland"
)


def test_persist_lineage_transaction():

    result = persist_lineage(
        ROOT
    )

    assert result["result"] == "PASS"
    assert result["count"] >= 1
