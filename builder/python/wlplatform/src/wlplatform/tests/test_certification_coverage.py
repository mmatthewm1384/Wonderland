from pathlib import Path

from wlplatform.certification_coverage import (
    certification_coverage,
)


ROOT = Path(
    "/Users/wonderland/Wonderland"
)


def test_certification_coverage():

    result = certification_coverage(
        ROOT,
        [
            "mirror",
        ],
    )

    assert result["result"] == "PASS"
    assert result["certified"] == 1
