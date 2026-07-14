from __future__ import annotations

import json
import shutil
import subprocess
from dataclasses import dataclass, asdict


@dataclass
class Container:
    name: str
    image: str
    status: str
    running: bool


class ContainerRuntime:
    def __init__(self, lima_instance: str = "wonderland-rootless"):
        self.lima_instance = lima_instance

    def _nerdctl_cmd(self, args: list[str]) -> list[str]:
        if shutil.which("nerdctl"):
            return ["nerdctl", *args]

        return ["limactl", "shell", self.lima_instance, "nerdctl", *args]

    def lima_running(self) -> bool:
        p = subprocess.run(
            ["limactl", "list", "--json"],
            text=True,
            capture_output=True,
            check=False,
        )

        if p.returncode != 0:
            return False

        for line in p.stdout.splitlines():
            try:
                item = json.loads(line)
            except json.JSONDecodeError:
                continue

            if item.get("name") == self.lima_instance and item.get("status") == "Running":
                return True

        return False

    def list_containers(self) -> list[Container]:
        p = subprocess.run(
            self._nerdctl_cmd(["ps", "-a", "--format", "json"]),
            text=True,
            capture_output=True,
            check=False,
        )

        containers: list[Container] = []

        for line in p.stdout.splitlines():
            try:
                item = json.loads(line)
            except json.JSONDecodeError:
                continue

            name = item.get("Names") or item.get("Name") or ""
            status = item.get("Status") or ""

            containers.append(
                Container(
                    name=name,
                    image=item.get("Image", ""),
                    status=status,
                    running=status.lower().startswith("up"),
                )
            )

        return containers

    def start(self, name: str) -> bool:
        p = subprocess.run(
            self._nerdctl_cmd(["start", name]),
            text=True,
            capture_output=True,
            check=False,
        )
        return p.returncode == 0

    def to_dicts(self) -> list[dict]:
        return [asdict(c) for c in self.list_containers()]
