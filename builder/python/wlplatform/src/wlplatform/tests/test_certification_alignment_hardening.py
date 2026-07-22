from pathlib import Path

from wlplatform.engine_contract import EngineContract
from wlplatform.certification_alignment import verify_alignment
from wlplatform.engines import get_engine


ROOT = Path("/Users/wonderland/Wonderland")


def test_certification_alignment():

    engines = [
        get_engine(
            "mirror",
            ROOT,
        ),
        get_engine(
            "registry",
            ROOT,
        ),
        get_engine(
            "architecture",
            ROOT,
        ),
    ]

    result = verify_alignment(
        ROOT,
        engines,
    )

    assert result["result"] == "PASS", result
