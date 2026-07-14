from __future__ import annotations

import json
import shutil
import subprocess
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def state_dir() -> Path:
    path = repo_root() / "state" / "runtime"
    path.mkdir(parents=True, exist_ok=True)
    return path


def command_exists(name: str) -> bool:
    return shutil.which(name) is not None


def run(cmd: list[str], timeout: float = 20.0) -> bool:
    try:
        subprocess.run(
            cmd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=timeout,
            check=True,
        )
        return True
    except Exception:
        return False


def pgrep(name: str) -> bool:
    return run(["pgrep", "-f", name], timeout=5)


def lima_list() -> list[dict[str, Any]]:
    if not command_exists("limactl"):
        return []

    try:
        result = subprocess.run(
            ["limactl", "list", "--json"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            timeout=10,
            check=True,
        )
    except Exception:
        return []

    items: list[dict[str, Any]] = []
    for line in result.stdout.splitlines():
        try:
            items.append(json.loads(line))
        except json.JSONDecodeError:
            continue
    return items


def lima_exists(instance: str) -> bool:
    if not command_exists("limactl"):
        return False
    return run(["limactl", "list", instance], timeout=10)


def lima_running(instance: str) -> bool:
    return any(
        item.get("name") == instance and item.get("status") == "Running"
        for item in lima_list()
    )


def start_lima(instance: str) -> bool:
    if not command_exists("limactl"):
        return False
    if not lima_exists(instance):
        return False
    return run(["limactl", "start", instance], timeout=120)


def nerdctl_in_wonderland() -> bool:
    if not command_exists("limactl"):
        return False

    for instance in ("wonderland-rootless", "wonderland-os-builder"):
        if lima_running(instance):
            if run(["limactl", "shell", instance, "nerdctl", "info"], timeout=30):
                return True

    return False


@dataclass
class HealthResult:
    healthy: bool
    status: str
    message: str
    latency: float | None = None
    metadata: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass
class Service:
    name: str
    description: str = ""
    required: bool = False
    timeout: float = 30.0
    dependencies: list[str] = field(default_factory=list)
    full_only: bool = False
    startup_priority: int = 100
    restartable: bool = True
    health_interval: int = 30

    def health(self) -> HealthResult:
        healthy = self.check()
        return HealthResult(
            healthy=healthy,
            status="ready" if healthy else "unavailable",
            message="ready" if healthy else "not healthy",
        )

    def check(self) -> bool:
        return True

    def start(self) -> bool:
        return self.check()

    def stop(self) -> bool:
        return True

    def metadata(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "description": self.description,
            "required": self.required,
            "timeout": self.timeout,
            "dependencies": self.dependencies,
            "full_only": self.full_only,
            "startup_priority": self.startup_priority,
            "restartable": self.restartable,
            "health_interval": self.health_interval,
        }
