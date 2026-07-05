from __future__ import annotations

from pathlib import Path

from wlknowledge.fs import iter_files, rel
from wlknowledge.model import Entity

SERVICE_NAMES = {"compose.yml", "docker-compose.yml", "docker-compose.yaml"}


def scan_services(root: Path) -> list[Entity]:
    out: list[Entity] = []
    for path in sorted(iter_files(root)):
        if path.suffix in {".service", ".timer", ".plist"} or path.name in SERVICE_NAMES:
            out.append(Entity(name=path.name, path=rel(root, path), type=path.suffix.removeprefix(".") or path.name))
    return out
