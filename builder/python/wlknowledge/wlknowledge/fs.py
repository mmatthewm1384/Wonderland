from __future__ import annotations

from pathlib import Path


IGNORE_NAMES = {
    ".git",
    "node_modules",
    "__pycache__",
    ".venv",
    "venv",
    ".build",
    "target",
    "DerivedData",
}


def is_ignored(path: Path) -> bool:
    return any(part in IGNORE_NAMES for part in path.parts)


def rel(root: Path, path: Path) -> str:
    return path.relative_to(root).as_posix()


def iter_files(root: Path):
    for path in root.rglob("*"):
        if path.is_file() and not is_ignored(path):
            yield path


def iter_dirs(root: Path):
    for path in root.rglob("*"):
        if path.is_dir() and not is_ignored(path):
            yield path
