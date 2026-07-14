from __future__ import annotations

from dataclasses import asdict, dataclass, field


@dataclass(frozen=True)
class LifecycleStage:
    id: str
    title: str
    command: list[str]
    depends_on: list[str] = field(default_factory=list)
    required: bool = True
    timeout: int = 60
    health: list[str] = field(default_factory=list)


@dataclass(frozen=True)
class LifecycleGraph:
    name: str
    description: str
    stages: list[LifecycleStage]

    def to_dict(self) -> dict:
        return asdict(self)


def graphs(root_bin: str) -> dict[str, LifecycleGraph]:
    def bin_cmd(name: str, *args: str) -> list[str]:
        return [f"{root_bin}/{name}", *args]

    return {
        "START": LifecycleGraph(
            name="START",
            description="Start Wonderland through Runtime Engine authority.",
            stages=[
                LifecycleStage(
                    id="runtime-engine",
                    title="Runtime Engine Start",
                    command=bin_cmd("wl-runtime-engine", "start"),
                    health=bin_cmd("wl-runtime-engine", "health"),
                ),
            ],
        ),
        "STOP": LifecycleGraph(
            name="STOP",
            description="Stop Wonderland through Runtime Engine authority.",
            stages=[
                LifecycleStage(
                    id="runtime-engine",
                    title="Runtime Engine Stop",
                    command=bin_cmd("wl-runtime-engine", "stop"),
                    health=bin_cmd("wl-runtime-engine", "health"),
                ),
            ],
        ),
        "RESTART": LifecycleGraph(
            name="RESTART",
            description="Restart Wonderland runtime.",
            stages=[],
        ),
        "SUSPEND": LifecycleGraph(
            name="SUSPEND",
            description="Pause runtime while preserving state.",
            stages=[],
        ),
        "RESUME": LifecycleGraph(
            name="RESUME",
            description="Resume suspended runtime.",
            stages=[],
        ),
        "RELOAD": LifecycleGraph(
            name="RELOAD",
            description="Reload configuration, registries, and policies.",
            stages=[],
        ),
        "RECOVER": LifecycleGraph(
            name="RECOVER",
            description="Recover from degraded or unknown runtime state.",
            stages=[],
        ),
        "SAFE_MODE": LifecycleGraph(
            name="SAFE_MODE",
            description="Start minimal runtime for debugging.",
            stages=[],
        ),
        "MAINTENANCE": LifecycleGraph(
            name="MAINTENANCE",
            description="Enter audited maintenance mode.",
            stages=[],
        ),
        "SNAPSHOT": LifecycleGraph(
            name="SNAPSHOT",
            description="Create crash-consistent runtime snapshot.",
            stages=[],
        ),
    }


def list_graphs(root_bin: str) -> list[dict]:
    return [graph.to_dict() for graph in graphs(root_bin).values()]


def get_graph(root_bin: str, name: str) -> LifecycleGraph | None:
    return graphs(root_bin).get(name)
