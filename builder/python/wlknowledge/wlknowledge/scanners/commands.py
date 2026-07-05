from __future__ import annotations

from pathlib import Path
import os

from wlknowledge.fs import rel
from wlknowledge.model import Entity


def scan_commands(root: Path) -> list[Entity]:
    bin_dir = root / "bin"
    if not bin_dir.exists():
        return []

    out: list[Entity] = []
    for path in sorted(bin_dir.iterdir()):
        if path.is_file() and os.access(path, os.X_OK):
            out.append(Entity(name=path.name, path=rel(root, path), type="command"))
    return out
