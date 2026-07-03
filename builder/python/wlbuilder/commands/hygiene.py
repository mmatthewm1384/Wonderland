from __future__ import annotations

import subprocess
from pathlib import Path

GENERATED_PATHS = (
    "builder/python/wlbuilder.egg-info/SOURCES.txt",
    "vault/08-Operations/state/latest.json",
    "vault/chaos/chaos-aether.json",
    "vault/chaos/scheduler-audit.jsonl",
    "vault/ephemeral-runs.log",
)


def repo_root() -> Path:
    return Path(__file__).resolve().parents[4]


def check() -> int:
    root = repo_root()
    dirty: list[str] = []

    print("==> Checking generated/runtime state")

    for path in GENERATED_PATHS:
        result = subprocess.run(
            ["git", "status", "--short", "--", path],
            cwd=root,
            text=True,
            capture_output=True,
            check=False,
        )
        if result.stdout.strip():
            dirty.append(path)
            print(f"DIRTY: {path}")

    if dirty:
        print()
        print("Generated/runtime files are dirty.")
        print("Restore with:")
        print()
        print("bin/wl builder hygiene restore")
        return 1

    print("PASS: generated/runtime state is clean")
    return 0


def restore() -> int:
    root = repo_root()
    subprocess.run(["git", "restore", *GENERATED_PATHS], cwd=root, check=True)
    print("PASS: generated/runtime state restored")
    return 0


def run(action: str = "check") -> int:
    if action == "check":
        return check()
    if action == "restore":
        return restore()

    print(f"FAIL: invalid hygiene action: {action}")
    return 2
