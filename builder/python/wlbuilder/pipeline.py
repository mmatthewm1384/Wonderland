from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages import default_pipeline


def execute(context: BuilderContext) -> int:
    for stage in default_pipeline():
        result = stage.run(context)

        status = "PASS" if result.success else "FAIL"
        detail = f": {result.message}" if result.message else ""
        print(f"{status} stage:{result.name}{detail}")

        if not result.success:
            return 1

    return 0
