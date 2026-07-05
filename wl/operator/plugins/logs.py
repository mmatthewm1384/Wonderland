from __future__ import annotations

from wl.operator.core import Capability, Health, HealthState, OperatorContext


def capability(context: OperatorContext) -> Capability:
    return Capability(
        name="logs",
        title="Logs",
        shortcut="L",
        window="logs",
        command="find state logs vault/chaos -maxdepth 3 -type f 2>/dev/null | sort | tail -80",
        health=Health("logs", HealthState.UNKNOWN, "local logs"),
    )
