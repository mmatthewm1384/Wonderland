from __future__ import annotations

from wlcli.output import CommandResult


def render(result: CommandResult) -> int:
    print(result.to_json())
    return result.exit_code()
