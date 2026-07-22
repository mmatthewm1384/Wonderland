"""
Certification Engine 1.1 Regression Guards

Protects:
- CertificationError identity
- certification root boundary
- public certification API contract
"""

from pathlib import Path

import pytest


def test_certification_error_identity():
    """
    Ensure canonical exception ownership.
    """

    from wlplatform.certification import CertificationError
    from wlplatform.certification.errors import (
        CertificationError as CanonicalCertificationError,
    )

    assert CertificationError is CanonicalCertificationError


def test_certification_rejects_filesystem_root():
    """
    Prevent certification against filesystem root.
    """

    from wlplatform.certification import (
        CertificationError,
        certify,
    )

    with pytest.raises(CertificationError):
        certify(root=Path("/"))


@pytest.mark.parametrize(
    "invalid_root",
    [
        "/",
        "/../",
    ],
)
def test_certification_rejects_invalid_roots(invalid_root):
    """
    Prevent ownership escape paths.
    """

    from wlplatform.certification import (
        CertificationError,
        certify,
    )

    with pytest.raises(CertificationError):
        certify(root=Path(invalid_root))


def test_certification_allows_valid_root(tmp_path):
    """
    Confirm valid certification roots remain accepted.
    """

    from wlplatform.certification import certify

    result = certify(root=tmp_path)

    assert result is not None
