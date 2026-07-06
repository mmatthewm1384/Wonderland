from __future__ import annotations

from dataclasses import asdict, dataclass


@dataclass(frozen=True)
class LifecycleAction:
    name: str
    graph: str
    from_state: str
    to_state: str
    status: str
    description: str


ACTIONS: dict[str, LifecycleAction] = {
    "start": LifecycleAction("start", "START", "STOPPED", "RUNNING", "implemented", "Start Wonderland runtime."),
    "stop": LifecycleAction("stop", "STOP", "RUNNING", "STOPPED", "implemented", "Gracefully stop Wonderland runtime."),
    "restart": LifecycleAction("restart", "RESTART", "RUNNING", "RUNNING", "planned", "Stop then start as one transaction."),
    "suspend": LifecycleAction("suspend", "SUSPEND", "RUNNING", "SUSPENDED", "planned", "Pause runtime while preserving state."),
    "resume": LifecycleAction("resume", "RESUME", "SUSPENDED", "RUNNING", "planned", "Resume from suspended state."),
    "reload": LifecycleAction("reload", "RELOAD", "RUNNING", "RUNNING", "planned", "Reload config, registries, and policies."),
    "recover": LifecycleAction("recover", "RECOVER", "DEGRADED", "RUNNING", "planned", "Recover from failed or unknown runtime state."),
    "safe-mode": LifecycleAction("safe-mode", "SAFE_MODE", "STOPPED", "RUNNING_SAFE", "planned", "Start only essential services."),
    "maintenance": LifecycleAction("maintenance", "MAINTENANCE", "RUNNING", "MAINTENANCE", "planned", "Enter audited maintenance mode."),
    "snapshot": LifecycleAction("snapshot", "SNAPSHOT", "RUNNING", "RUNNING", "planned", "Create crash-consistent runtime snapshot."),
}


def get_action(name: str) -> LifecycleAction | None:
    return ACTIONS.get(name)


def list_actions() -> list[dict]:
    return [asdict(action) for action in ACTIONS.values()]
