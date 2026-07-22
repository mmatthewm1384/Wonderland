from .errors import CertificationError

"""
Wonderland Certification Engine

Public certification API.
"""

from pathlib import Path

from .errors import (
    CertificationError,
    CertificationArtifactError,
    CertificationValidationError,
)

from .contract import (
    CertificationContract,
    CertificationResult,
)

from .ownership import (
    OWNERSHIP,
)

from .platform import (
    certify as platform_certify,
)

from .certifier import (
    certify as _engine_certify,
)

from ..engine import (
    PlatformCertificationEngine,
)


def certify(controller=None, include_optional=False, **kwargs):
    """
    Public certification API compatibility boundary.
    """

    root = kwargs.get("root")

    if controller is not None:
        context = getattr(controller, "context", None)

        if context is not None:
            root = getattr(context, "root", None)

        if root is None:
            root = getattr(controller, "root", None)

    if root is None:
        raise CertificationError(
            "Certification root required"
        )

    root = Path(root).expanduser().resolve()

    return _engine_certify(
        root=root,
        include_optional=include_optional,
    )
