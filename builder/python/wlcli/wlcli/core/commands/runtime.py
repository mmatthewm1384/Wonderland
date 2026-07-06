from __future__ import annotations

from wlcli.output import CommandResult, ResultLine
from wlcli.runtime.context import RuntimeContext
from wlcli.runtime.interface import PlatformOperations
from wlcli.core.commands.base import CommandSpec


class RuntimeStatusCommand:
    spec = CommandSpec(
        name="runtime.status",
        namespace="runtime",
        description="Show Runtime Engine status",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        rootless = PlatformOperations(context).rootless("status")
        services = PlatformOperations(context).services("status")

        lines = [
            ResultLine(rootless.state, "Rootless runtime", rootless.message),
            ResultLine(services.state, "Services", services.message),
        ]

        state = "FAIL" if any(line.state == "FAIL" for line in lines) else "PASS"

        return CommandResult(
            title="Wonderland Runtime Status",
            state=state,
            message="runtime status collected" if state == "PASS" else "runtime degraded",
            lines=lines,
            metadata={
                "Runtime instance": context.runtime_instance,
                "Profile": context.profile,
            },
        )


class RuntimeBetaCommand:
    spec = CommandSpec(
        name="runtime.beta",
        namespace="runtime",
        description="Show Runtime Engine 1.0 Beta architecture status",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        from wlcli.core.architecture import verify_beta_architecture

        return verify_beta_architecture(context.root)


class RuntimeContextCommand:
    spec = CommandSpec(
        name="runtime.context",
        namespace="runtime",
        description="Show RuntimeContext",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        return CommandResult(
            title="Wonderland Runtime Context",
            state="PASS",
            message="runtime context loaded",
            lines=[
                ResultLine("PASS", "Root", str(context.root)),
                ResultLine("PASS", "Log dir", str(context.log_dir)),
                ResultLine("PASS", "State dir", str(context.state_dir)),
                ResultLine("PASS", "Runtime instance", context.runtime_instance),
                ResultLine("PASS", "Profile", context.profile),
                ResultLine("PASS", "Channel", context.channel),
                ResultLine("PASS", "Version", context.version),
            ],
            payload=context.to_dict(),
        )
