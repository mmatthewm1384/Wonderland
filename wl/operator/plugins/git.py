from __future__ import annotations

from wl.operator.core import Capability, Health, HealthState, OperatorContext


def capability(context: OperatorContext) -> Capability:
    exists = (context.root / ".git").exists()

    return Capability(
        name="git",
        title="Git",
        shortcut="g",
        window="git",
        command="git status --short",
        health=Health(
            "git",
            HealthState.HEALTHY if exists else HealthState.UNKNOWN,
            "repository available" if exists else "not a git repository",
        ),
    )
