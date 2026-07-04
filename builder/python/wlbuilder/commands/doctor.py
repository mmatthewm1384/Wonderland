from __future__ import annotations

from wlbuilder.doctor import run_doctor
from wlbuilder.runtime_context import RuntimeContext


def run(context: RuntimeContext) -> int:
    return run_doctor(context.repo_root)
