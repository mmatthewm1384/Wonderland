from __future__ import annotations

from pathlib import Path

from wlknowledge.fs import is_ignored, rel
from wlknowledge.model import Entity


def classify_application(path: Path) -> str:
    if (path / "src-tauri").is_dir():
        return "tauri-app"

    if (path / "Package.swift").is_file():
        return "swift-package"

    if (path / "package.json").is_file():
        return "node-app"

    return "application-directory"


def scan_applications(root: Path) -> list[Entity]:
    apps_dir = root / "apps"
    if not apps_dir.exists():
        return []

    applications: list[Entity] = []

    for path in sorted(apps_dir.rglob("*")):
        if not path.is_dir() or is_ignored(path):
            continue

        kind = classify_application(path)

        if kind != "application-directory" or path.parent == apps_dir:
            applications.append(
                Entity(
                    name=path.name,
                    path=rel(root, path),
                    kind=kind,
                )
            )

    return applications
