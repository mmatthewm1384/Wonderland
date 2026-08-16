from wlplatform.paths import repository_root

from wlplatform.paths import repository_root

from wlplatform.certification_coverage import (
    certification_coverage,
)


ROOT = repository_root()


def test_certification_coverage():

    result = certification_coverage(
        ROOT,
        [
            "mirror",
        ],
    )

    assert result["result"] == "PASS"
    assert result["certified"] == 1
