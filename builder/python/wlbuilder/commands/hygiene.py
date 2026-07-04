from __future__ import annotations

import subprocess
from pathlib import Path

RUNTIME_STATE = (
    "vault/08-Operations/state/latest.json",
    "vault/chaos/chaos-aether.json",
    "vault/chaos/scheduler-audit.jsonl",
    "vault/ephemeral-runs.log",
)


def repo_root() -> Path:
    return Path(__file__).resolve().parents[4]


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


def check() -> int:
    root = repo_root()
    dirty = _dirty_paths(root, RUNTIME_STATE)

    print("==> Checking repository hygiene")

    if dirty:
        print()
        print("Dirty runtime state:")
        for path in dirty:
            print(f"DIRTY: {path}")

        print()
        print("Restore with:")
        print("bin/wl builder hygiene restore")
        return 1

    print("PASS: runtime state is clean")
    return 0


def restore() -> int:
    root = repo_root()

    subprocess.run(
        ["git", "restore", *RUNTIME_STATE],
        cwd=root,
        check=True,
    )

    print("PASS: runtime state restored")
    return 0


def run(repo_root: Path, *, action: str = "check") -> int:
    if action == "check":
        return check()

    if action == "restore":
        return restore()

    print(f"FAIL: invalid hygiene action: {action}")
    return 2
