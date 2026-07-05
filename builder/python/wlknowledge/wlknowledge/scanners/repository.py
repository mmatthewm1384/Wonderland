from __future__ import annotations

from pathlib import Path
import subprocess

from wlknowledge.fs import iter_dirs, iter_files, rel


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
    top_level = []

    for path in sorted(root.iterdir()):
        if path.name == ".git":
            continue

        top_level.append(
            {
                "name": path.name,
                "path": rel(root, path),
                "kind": "directory" if path.is_dir() else "file",
            }
        )

    return {
        "root": str(root),
        "branch": git_value(root, "rev-parse", "--abbrev-ref", "HEAD"),
        "commit": git_value(root, "rev-parse", "--short", "HEAD"),
        "file_count": sum(1 for _ in iter_files(root)),
        "directory_count": sum(1 for _ in iter_dirs(root)),
        "top_level": top_level,
    }
