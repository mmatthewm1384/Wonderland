from __future__ import annotations

import json

from wlcli.output import CommandResult


def render(result: CommandResult) -> int:
    if result.payload is not None:
        print(json.dumps(result.payload, indent=2))
    else:
        print(result.to_json())
    return result.exit_code()
