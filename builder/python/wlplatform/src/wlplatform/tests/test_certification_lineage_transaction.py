from wlplatform.paths import repository_root

from wlplatform.paths import repository_root

from wlplatform.certification_lineage import (
    persist_lineage,
)


ROOT = repository_root()


def test_persist_lineage_transaction():

    result = persist_lineage(
        ROOT
    )

    assert result["result"] == "PASS"
    assert result["count"] >= 1
