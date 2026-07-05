from __future__ import annotations

from wl.operator.core import Capability, Health, HealthState, OperatorContext


def capability(context: OperatorContext) -> Capability:
    exists = (context.root / "vault" / "chaos").exists()

    return Capability(
        name="chaos",
        title="Chaos",
        shortcut="c",
        window="chaos",
        command="wl chaos status || wl-chaos-session status",
        health=Health(
            "chaos",
            HealthState.HEALTHY if exists else HealthState.UNKNOWN,
            "chaos state detected" if exists else "no chaos state",
        ),
    )
