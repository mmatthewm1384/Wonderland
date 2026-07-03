from __future__ import annotations

from pathlib import Path

from wlbuilder.verify import run_verify


def run(repo_root: Path) -> int:
    return run_verify(repo_root)
