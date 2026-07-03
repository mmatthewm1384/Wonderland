from __future__ import annotations

from pathlib import Path

from wlbuilder.context import create_context, ensure_output_dirs
from wlbuilder.pipeline import execute


def run(repo_root: Path, profile: str) -> int:
    context = create_context(repo_root, profile)
    ensure_output_dirs(context)

    results = execute(context)
    failed = False

    for result in results:
        status = "PASS" if result.success else "FAIL"
        print(f"{status} stage:{result.name} implementation:native: {result.message}")
        if not result.success:
            failed = True
            break

    return 1 if failed else 0
