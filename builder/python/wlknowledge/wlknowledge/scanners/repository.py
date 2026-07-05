from __future__ import annotations

from pathlib import Path
import subprocess


def git_value(root: Path, *args: str) -> str | None:
    try:
        return subprocess.check_output(
            ["git", *args],
            cwd=root,
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
    except Exception:
        return None


def scan_repository(root: Path) -> dict:
    return {
        "root": str(root),
        "branch": git_value(root, "rev-parse", "--abbrev-ref", "HEAD"),
        "commit": git_value(root, "rev-parse", "--short", "HEAD"),
    }
