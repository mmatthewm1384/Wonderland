from __future__ import annotations

import subprocess
from pathlib import Path

from wlbuilder.runtime_context import RuntimeContext


BUILDER_STATE: tuple[str, ...] = ()


def _dirty_paths(root: Path, paths: tuple[str, ...]) -> list[str]:
    dirty: list[str] = []

    for path in paths:
        result = subprocess.run(
            ["git", "status", "--short", "--", path],
            cwd=root,
            text=True,
            capture_output=True,
            check=False,
        )

        if result.stdout.strip():
            dirty.append(path)

    return dirty


def check(root: Path) -> int:
    print("==> Checking Builder repository hygiene")

    dirty = _dirty_paths(root, BUILDER_STATE)

    if dirty:
        print()
        print("Dirty Builder-managed state:")
        for path in dirty:
            print(f"DIRTY: {path}")

        print()
        print("Restore with:")
        print("bin/wl builder hygiene restore")
        return 1

    print("PASS: Builder-managed state is clean")
    return 0


def restore(root: Path) -> int:
    if not BUILDER_STATE:
        print("PASS: no Builder-managed runtime state to restore")
        return 0

    subprocess.run(
        ["git", "restore", *BUILDER_STATE],
        cwd=root,
        check=True,
    )

    print("PASS: Builder-managed runtime state restored")
    return 0


def run(context: RuntimeContext) -> int:
    action = context.hygiene_action

    if action == "check":
        return check(context.repo_root)

    if action == "restore":
        return restore(context.repo_root)

    print(f"FAIL: invalid hygiene action: {action}")
    return 2
