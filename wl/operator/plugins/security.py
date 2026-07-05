from __future__ import annotations

from wl.operator.core import Capability, Health, HealthState, OperatorContext


def capability(context: OperatorContext) -> Capability:
    return Capability(
        name="security",
        title="Security",
        shortcut="s",
        window="security",
        command="echo 'Future: wl security dashboard'",
        health=Health("security", HealthState.UNKNOWN, "planned"),
    )
