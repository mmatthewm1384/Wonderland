from __future__ import annotations

from wlcli.core.commands.base import CommandSpec
from wlcli.core.lifecycle import get_action, list_actions
from wlcli.core.runtime.context import RuntimeContext
from wlcli.output import CommandResult, ResultLine


class LifecycleShowCommand:
    spec = CommandSpec("lifecycle.show", "lifecycle", "Show lifecycle registry")

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        actions = list_actions()
        lines = [
            ResultLine(
                "PASS" if item["status"] == "implemented" else "WARN",
                item["name"],
                f'{item["graph"]}: {item["from_state"]} -> {item["to_state"]} ({item["status"]})',
            )
            for item in actions
        ]

        return CommandResult(
            title="Wonderland Runtime Lifecycle",
            state="PASS",
            message="lifecycle registry loaded",
            lines=lines,
            payload=actions,
        )
