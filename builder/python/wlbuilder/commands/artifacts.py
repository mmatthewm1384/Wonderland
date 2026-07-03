from __future__ import annotations

from pathlib import Path

from wlbuilder.context import create_context


def run(repo_root: Path) -> int:
    context = create_context(repo_root)

    for artifact in sorted(context.output_root.rglob("*")):
        if artifact.is_file():
            print(artifact.relative_to(context.repo_root))

    return 0
