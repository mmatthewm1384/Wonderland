"""
Wonderland PRISM capability.

Trusted artifact system:
- .prism  general secure artifacts
- .prismx encrypted media artifacts
"""

from .artifact import PrismArtifact
from .media.prismx import PrismXArtifact

__all__ = [
    "PrismArtifact",
    "PrismXArtifact",
]
