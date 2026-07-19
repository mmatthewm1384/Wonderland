from __future__ import annotations


from .certification.errors import CertificationError
def certify(
controller=None, include_optional=False, **kwargs):
    if controller is None and root is None:
        raise CertificationError('controller required')
    """
    Public certification API.

    Compatibility boundary for CLI and external callers.
    """

    root = (
        getattr(controller, "root", None)
        if controller is not None
        else None
    )

    if root is None:
        root = kwargs.get("root")

    if root is None:
        root = Path(root).resolve() if root else Path.cwd()

    return _certify_platform(root)




from .engine import PlatformCertificationEngine as CanonicalPlatformCertificationEngine

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

from .certification_registry import CertificationRegistry
from .certification_policy import CertificationPolicy



class CertificationError(Exception):
    """
    Raised when Wonderland platform certification fails.
    """

    pass





def certify(
controller=None, include_optional=False, **kwargs):
    """
    Compatibility wrapper.

    Canonical implementation:
        engine.PlatformCertificationEngine
    """

    from .engine import PlatformCertificationEngine

    root = kwargs.get(
        "root",
        getattr(
            controller,
            "root",
            Path(root).resolve() if root else Path.cwd(),
        ),
    )

    return PlatformCertificationEngine(
        root
    ).certify()
