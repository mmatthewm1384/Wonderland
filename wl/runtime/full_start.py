from __future__ import annotations

import shutil
import subprocess
from dataclasses import dataclass


@dataclass(frozen=True)
class StartTask:
    name: str
    command: list[str]
    required: bool = False


def command_exists(command: str) -> bool:
    return shutil.which(command) is not None


def run_task(task: StartTask) -> tuple[str, str, bool]:
    try:
        result = subprocess.run(
            task.command,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )

        if result.returncode == 0:
            return task.name, "pass", True

        status = "fail" if task.required else "warn"
        return task.name, status, not task.required

    except FileNotFoundError:
        status = "fail" if task.required else "warn"
        return task.name, status, not task.required


def full_start_tasks() -> list[StartTask]:
    tasks: list[StartTask] = []

    if command_exists("nerdctl"):
        tasks.append(StartTask("nerdctl", ["nerdctl", "version"], required=False))

    if command_exists("lima"):
        tasks.append(StartTask("wonderland-os-builder", ["lima", "list"], required=False))

    if command_exists("docker"):
        tasks.append(StartTask("docker", ["docker", "version"], required=False))

    if command_exists("brew"):
        tasks.extend(
            [
                StartTask("grafana", ["brew", "services", "list"], required=False),
            ]
        )

    return tasks


def run_full_start() -> list[tuple[str, str, bool]]:
    return [run_task(task) for task in full_start_tasks()]
