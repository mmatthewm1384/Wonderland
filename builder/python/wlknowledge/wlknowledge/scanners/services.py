from __future__ import annotations

from pathlib import Path

from wlknowledge.fs import iter_files, rel
from wlknowledge.model import Entity


SERVICE_NAMES = {
    "compose.yml",
    "docker-compose.yml",
    "docker-compose.yaml",
}


def classify_service(path: Path) -> str | None:
    if path.suffix == ".service":
        return "systemd-service"

    if path.suffix == ".timer":
        return "systemd-timer"

    if path.suffix == ".plist":
        return "launchd-plist"

    if path.name in SERVICE_NAMES:
        return "compose"

    return None


def scan_services(root: Path) -> list[Entity]:
    services: list[Entity] = []

    for path in sorted(iter_files(root)):
        kind = classify_service(path)
        if not kind:
            continue

        services.append(
            Entity(
                name=path.name,
                path=rel(root, path),
                kind=kind,
            )
        )

    return services
