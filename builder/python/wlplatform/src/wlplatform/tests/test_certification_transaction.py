from pathlib import Path

from wlplatform.engines import get_engine
from wlplatform.certification_transaction import (
    certify_transaction,
)


ROOT = Path(
    "/Users/wonderland/Wonderland"
)


def test_certification_transaction():

    engine = get_engine(
        "mirror",
        ROOT,
    )

    result = certify_transaction(
        engine
    )

    assert (
        result["validation"]["valid"]
        is True
    )
