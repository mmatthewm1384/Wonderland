from __future__ import annotations

import json

from wlbuilder.native_state import read_state, state_path
from wlbuilder.runtime_context import RuntimeContext


def run(context: RuntimeContext) -> int:
    builder = context.builder
    state = read_state(builder)

    if context.as_json:
        print(
            json.dumps(
                {
                    "path": str(state_path(builder)),
                    "state": state,
                },
                indent=2,
                sort_keys=True,
            )
        )
        return 0

    print(f"native_state_file: {state_path(builder)}")

    if not state:
        print("native_state: none")
        return 0

    print("native_state:")
    for name in sorted(state):
        print(f"  - {name}")

    return 0
