from __future__ import annotations

from pathlib import Path

from wlplatform.oblivion.capability_resolver import (
    CapabilityResolver,
)


def execute(
    root: Path,
    action: str,
    args: list[str] | None = None,
):
    args = list(args or [])

    if action != "capability":
        raise RuntimeError(
            f"Unknown Oblivion action: {action}"
        )

    if not args:
        raise RuntimeError(
            "Usage: wl oblivion capability "
            "resolve <package> <capability>"
        )

    operation = args[0]

    if operation != "resolve":
        raise RuntimeError(
            f"Unknown Oblivion capability operation: {operation}"
        )

    if len(args) != 3:
        raise RuntimeError(
            "Usage: wl oblivion capability "
            "resolve <package> <capability>"
        )

    package = args[1]
    capability = args[2]

    return CapabilityResolver(
        root
    ).resolve(
        package,
        capability,
    )
