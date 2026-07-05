from __future__ import annotations

from pathlib import Path

from wl.operator.core import Capability, Health, HealthState, OperatorContext


def path_exists(root: Path, path: str) -> bool:
    return (root / path).exists()


def discover(context: OperatorContext) -> list[Capability]:
    root = context.root

    return [
        Capability(
            name="runtime",
            title="Runtime",
            shortcut="r",
            window="runtime",
            command="wl runtime status",
            health=Health(
                "runtime",
                HealthState.HEALTHY if path_exists(root, "state/runtime") else HealthState.UNKNOWN,
                "runtime state detected" if path_exists(root, "state/runtime") else "no runtime state",
            ),
        ),
        Capability(
            name="builder",
            title="Builder",
            shortcut="b",
            window="builder",
            command="wl builder status || wl builder doctor",
            health=Health(
                "builder",
                HealthState.HEALTHY if path_exists(root, "builder/python/wlbuilder") else HealthState.UNKNOWN,
                "builder available" if path_exists(root, "builder/python/wlbuilder") else "builder not detected",
            ),
        ),
        Capability(
            name="chaos",
            title="Chaos",
            shortcut="c",
            window="chaos",
            command="wl chaos status || wl-chaos-session status",
            health=Health(
                "chaos",
                HealthState.HEALTHY if path_exists(root, "vault/chaos") else HealthState.UNKNOWN,
                "chaos state detected" if path_exists(root, "vault/chaos") else "no chaos state",
            ),
        ),
        Capability(
            name="security",
            title="Security",
            shortcut="s",
            window="security",
            command="echo 'Future: wl security dashboard'",
            health=Health("security", HealthState.UNKNOWN, "planned"),
        ),
        Capability(
            name="git",
            title="Git",
            shortcut="g",
            window="git",
            command="git status --short",
            health=Health("git", HealthState.HEALTHY, "repository available"),
        ),
        Capability(
            name="logs",
            title="Logs",
            shortcut="L",
            window="logs",
            command="find state logs vault/chaos -maxdepth 3 -type f 2>/dev/null | sort | tail -80",
            health=Health("logs", HealthState.UNKNOWN, "local logs"),
        ),
    ]
