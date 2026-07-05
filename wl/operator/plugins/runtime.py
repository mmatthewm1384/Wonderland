from __future__ import annotations

from wl.operator.core import Capability, Health, HealthState, OperatorContext


def capability(context: OperatorContext) -> Capability:
    state_dir = context.root / "state" / "runtime"
    exists = state_dir.exists()

    return Capability(
        name="runtime",
        title="Runtime",
        shortcut="r",
        window="runtime",
        command="wl runtime status",
        health=Health(
            "runtime",
            HealthState.HEALTHY if exists else HealthState.UNKNOWN,
            "runtime state detected" if exists else "no runtime state",
        ),
    )
