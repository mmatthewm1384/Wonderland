from pathlib import Path

from .context import PlatformContext


def repository_root() -> Path:
    return PlatformContext.discover().root
