"""
Wonderland Certification Engine

Public certification API.
"""

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



def certify(controller=None, include_optional=False, **kwargs):
    """
    Public certification API compatibility wrapper.
    """

    from pathlib import Path

    def resolve_root():
        candidates = []

        # Explicit caller root
        if kwargs.get("root"):
            candidates.append(Path(kwargs["root"]))

        # Controller root
        if controller is not None:
            value = getattr(controller, "root", None)
            if value:
                candidates.append(Path(value))

        # Current directory and parents
        cwd = Path.cwd()

        candidates.append(cwd)

        candidates.extend(cwd.parents)

        # Module location fallback
        here = Path(__file__).resolve()

        candidates.extend(here.parents)

        for candidate in candidates:
            candidate = candidate.resolve()

            if (
                (candidate / "vault").exists()
                and
                (candidate / "builder").exists()
            ):
                return candidate

        raise RuntimeError(
            "Unable to resolve Wonderland repository root"
        )

    root = resolve_root()

    print(
        root,
        flush=True,
    )

    return _engine_certify(
        root,
        include_optional=include_optional,
    )


__all__ = [
    "CertificationError",
    "CertificationArtifactError",
    "CertificationValidationError",
    "CertificationContract",
    "CertificationResult",
    "OWNERSHIP",
    "platform_certify",
    "certify",
]
