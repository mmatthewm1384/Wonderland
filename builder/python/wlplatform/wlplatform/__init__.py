"""
Wonderland Platform Engine.

The Platform Engine coordinates subsystem verification and certification
without owning or duplicating subsystem implementation logic.
"""

from .version import __version__
from .result import CheckResult, PlatformReport, Status
from .controller import PlatformController

__all__ = [
    "CheckResult",
    "PlatformController",
    "PlatformReport",
    "Status",
    "__version__",
]
