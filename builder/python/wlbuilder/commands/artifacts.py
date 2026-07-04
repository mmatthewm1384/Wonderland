from __future__ import annotations

from pathlib import Path

from wlbuilder.context import create_context
from wlbuilder.runtime_context import RuntimeContext


EXCLUDED_DIRS = {"tmp", "cache", ".git", "__pycache__"}


def _is_excluded(path: Path, root: Path) -> bool:
    try:
        relative = path.relative_to(root)
    except ValueError:
        return False

    return bool(relative.parts and relative.parts[0] in EXCLUDED_DIRS)


def run(context: RuntimeContext) -> int:
    builder_context = create_context(context.repo_root)

    if not builder_context.output_root.exists():
        return 0

    for artifact in sorted(builder_context.output_root.rglob("*")):
        if _is_excluded(artifact, builder_context.output_root):
            continue

        try:
            if artifact.is_file():
                print(artifact)
        except PermissionError:
            continue

    return 0
