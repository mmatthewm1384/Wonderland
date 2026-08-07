from __future__ import annotations

from ..context import PlatformContext


RuntimeContext = PlatformContext


def get_context():
    return PlatformContext.discover()


__all__ = [
    "RuntimeContext",
    "get_context",
]
