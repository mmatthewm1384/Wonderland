from __future__ import annotations

from wlbuilder.context import ensure_output_dirs
from wlbuilder.pipeline import execute
from wlbuilder.runtime_context import RuntimeContext


def run(context: RuntimeContext) -> int:
    builder = context.builder
    ensure_output_dirs(builder)

    results = execute(builder)
    failed = False

    for result in results:
        status = "PASS" if result.success else "FAIL"
        print(f"{status} stage:{result.name} implementation:native: {result.message}")

        if not result.success:
            failed = True
            break

    return 1 if failed else 0
