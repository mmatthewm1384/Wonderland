from wlplatform.paths import repository_root

from wlplatform.paths import repository_root

from wlplatform.certification_registry import (
    CertificationRegistry,
)


ROOT = repository_root()


def test_certification_registry_integrity():

    registry = CertificationRegistry(
        ROOT
    )

    result = (
        registry
        .validate_active_integrity()
    )

    assert result["valid"], result
