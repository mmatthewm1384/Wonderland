from __future__ import annotations

import json
from pathlib import Path

from wlbuilder.context import create_context
from wlbuilder.native_state import read_state, state_path


def run(repo_root: Path, *, as_json: bool = False) -> int:
    context = create_context(repo_root)
    state = read_state(context)

    if as_json:
        print(
            json.dumps(
                {
                    "path": str(state_path(context)),
                    "state": state,
                },
                indent=2,
                sort_keys=True,
            )
        )
        return 0

    print(f"native_state_file: {state_path(context)}")

    if not state:
        print("native_state: none")
        return 0

    print("native_state:")
    for name in sorted(state):
        print(f"  - {name}")

    return 0
