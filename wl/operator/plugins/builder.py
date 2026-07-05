from __future__ import annotations

from wl.operator.core import Capability, Health, HealthState, OperatorContext


def capability(context: OperatorContext) -> Capability:
    exists = (context.root / "builder" / "python" / "wlbuilder").exists()

    return Capability(
        name="builder",
        title="Builder",
        shortcut="b",
        window="builder",
        command="wl builder status || wl builder doctor",
        health=Health(
            "builder",
            HealthState.HEALTHY if exists else HealthState.UNKNOWN,
            "builder available" if exists else "builder not detected",
        ),
    )
