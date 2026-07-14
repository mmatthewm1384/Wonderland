from __future__ import annotations

from wlcli.output import CommandResult, ResultLine
from wlcli.core.runtime.context import RuntimeContext
from wlcli.core.runtime.operation import BashOperationRunner


class PlatformOperations:
    def __init__(self, context: RuntimeContext):
        self.context = context
        self.runner = BashOperationRunner(context)

    def rootless(self, action: str) -> CommandResult:
        result = self.runner.run(
            f"rootless-{action}",
            [str(self.context.bin("wl-rootless")), action],
        )
        state = "PASS" if result.passed else "FAIL"
        return CommandResult(
            title=f"Rootless {action}",
            state=state,
            message="operation complete" if result.passed else "operation failed",
            lines=[ResultLine(state, "wl-rootless", result.log, result.duration)],
        )

    def services(self, action: str) -> CommandResult:
        result = self.runner.run(
            f"services-{action}",
            [str(self.context.bin("wl-services")), action],
        )
        state = "PASS" if result.passed else "FAIL"
        return CommandResult(
            title=f"Services {action}",
            state=state,
            message="operation complete" if result.passed else "operation failed",
            lines=[ResultLine(state, "wl-services", result.log, result.duration)],
        )

    def apps(self, action: str) -> CommandResult:
        result = self.runner.run(
            f"apps-{action}",
            [str(self.context.bin("wl-apps")), action],
        )
        state = "PASS" if result.passed else "WARN"
        return CommandResult(
            title=f"Applications {action}",
            state=state,
            message="operation complete" if result.passed else "optional operation failed",
            lines=[ResultLine(state, "wl-apps", result.log, result.duration)],
        )
