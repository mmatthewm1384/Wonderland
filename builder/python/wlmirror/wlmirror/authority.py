from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

from .context import MirrorContext


AUTHORITY_CANDIDATES = (
    "vault/05-Registry/storage/mirror.json",
    "vault/05-Registry/mirror/authority.json",
    "vault/05-Registry/mirror.json",
    "config/mirror.json",
    "vault/08-Operations/state/mirror-authority.json",
)


def find_authority_file(
    context: MirrorContext,
) -> Path | None:
    for relative in AUTHORITY_CANDIDATES:
        candidate = context.root / relative

        if candidate.is_file():
            return candidate

    return None


def load_authority(
    context: MirrorContext,
) -> tuple[Path | None, dict[str, Any]]:
    path = find_authority_file(context)

    if path is None:
        return None, {}

    payload = json.loads(path.read_text())

    if not isinstance(payload, dict):
        raise ValueError(
            f"Mirror authority must be an object: {path}"
        )

    return path, payload


def _path_value(
    payload: dict[str, Any],
    names: tuple[str, ...],
) -> str | None:
    for name in names:
        value = payload.get(name)

        if isinstance(value, str) and value.strip():
            return value.strip()

    for container_name in (
        "paths",
        "storage",
        "mirror",
        "authority",
    ):
        container = payload.get(container_name)

        if not isinstance(container, dict):
            continue

        for name in names:
            value = container.get(name)

            if isinstance(value, str) and value.strip():
                return value.strip()

    return None


def resolve_source(
    context: MirrorContext,
    payload: dict[str, Any],
) -> Path:
    configured = (
        os.environ.get("WL_MIRROR_SOURCE")
        or _path_value(
            payload,
            (
                "source",
                "source_root",
                "primary",
                "repository",
            ),
        )
    )

    if not configured:
        return context.root

    path = Path(configured).expanduser()

    if not path.is_absolute():
        path = context.root / path

    return path.resolve()


def resolve_destination(
    context: MirrorContext,
    payload: dict[str, Any],
) -> Path | None:
    configured = (
        os.environ.get("WL_MIRROR_DESTINATION")
        or os.environ.get("WL_MIRROR_TARGET")
        or _path_value(
            payload,
            (
                "destination",
                "destination_root",
                "target",
                "mirror_root",
                "secondary",
            ),
        )
    )

    if not configured:
        return None

    path = Path(configured).expanduser()

    if not path.is_absolute():
        path = context.root / path

    return path.resolve()
