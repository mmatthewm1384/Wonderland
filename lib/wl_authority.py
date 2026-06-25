from __future__ import annotations

import os
from pathlib import Path


def wl_home() -> Path:
    return Path(os.environ.get("WL_HOME", str(Path.home() / "Wonderland"))).expanduser()


def wl_root() -> Path:
    return Path(os.environ.get("WL_AUTHORITY_ROOT", str(wl_home()))).expanduser()


def wl_path(*parts: str) -> Path:
    return wl_root().joinpath(*parts)
