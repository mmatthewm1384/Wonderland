from __future__ import annotations

from pathlib import Path

from wlbuilder.doctor import run_doctor


def run(repo_root: Path) -> int:
    return run_doctor(repo_root)
