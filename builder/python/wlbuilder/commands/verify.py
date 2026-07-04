from __future__ import annotations

from wlbuilder.runtime_context import RuntimeContext
from wlbuilder.verify import run_verify


def run(context: RuntimeContext) -> int:
    return run_verify(context.repo_root)
