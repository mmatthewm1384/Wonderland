# builder/python/wlplatform/wlplatform/root.py

from pathlib import Path


def discover_root() -> Path:
    current = Path.cwd().resolve()

    for candidate in (current, *current.parents):
        if (candidate / "vault").exists():
            return candidate

    canonical = Path("/Users/wonderland/Wonderland")

    if (canonical / "vault").exists():
        return canonical

    raise RuntimeError(
        "Unable to locate Wonderland root"
    )
