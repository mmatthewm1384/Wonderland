"""
Wonderland Platform Engine
"""

__version__ = "1.1.0"


# Runtime Ecology exports
try:
    from .ecology import (
        RuntimeEcologyState,
        EcologyController,
    )
except ImportError:
    pass

