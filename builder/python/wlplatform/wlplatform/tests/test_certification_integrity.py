from pathlib import Path

from wlplatform.certification_registry import (
    CertificationRegistry,
)


ROOT = Path(
    "/Users/wonderland/Wonderland"
)


def test_certification_registry_integrity():

    registry = CertificationRegistry(
        ROOT
    )

    result = (
        registry
        .validate_active_integrity()
    )

    assert result["valid"], result
