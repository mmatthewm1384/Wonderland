"""
Wonderland Certification Errors

Backward-compatible public exceptions.
"""


class CertificationError(Exception):
    """
    Base certification failure.
    """
    pass


class CertificationArtifactError(CertificationError):
    """
    Certification artifact generation failure.
    """
    pass


class CertificationValidationError(CertificationError):
    """
    Certification validation failure.
    """
    pass
