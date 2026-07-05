from __future__ import annotations

from pathlib import Path

from wlknowledge.fs import ignored, rel
from wlknowledge.model import Entity


def scan_applications(root: Path) -> list[Entity]:
    apps = root / "apps"
    if not apps.exists():
        return []

    out: list[Entity] = []
    for path in sorted(apps.rglob("*")):
        if not path.is_dir() or ignored(path):
            continue

        kind = "application-directory"
        if (path / "Package.swift").exists():
            kind = "swift-package"
        elif (path / "src-tauri").exists():
            kind = "tauri-app"

        out.append(Entity(name=path.name, path=rel(root, path), type=kind))
    return out
