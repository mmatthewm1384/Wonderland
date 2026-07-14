from __future__ import annotations

import os
import platform
import subprocess
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class LaunchAgent:
    label: str
    plist: Path


def _plist(root: Path, label: str) -> Path:
    candidates = [
        root / "Library" / "LaunchAgents" / f"{label}.plist",
        Path.home() / "Library" / "LaunchAgents" / f"{label}.plist",
    ]

    for candidate in candidates:
        if candidate.exists():
            return candidate

    return candidates[0]


def default_launch_agents(root: Path) -> list[LaunchAgent]:
    labels = [
        "com.wonderland.chaos-menubar",
        "com.wonderland.chaos-scheduler",
        "com.wonderland.chaos-watchdog",
    ]
    return [LaunchAgent(label, _plist(root, label)) for label in labels]


def bootstrap_launch_agent(agent: LaunchAgent) -> tuple[bool, str]:
    if not agent.plist.exists():
        return False, f"missing plist: {agent.plist}"

    uid = os.getuid()
    subprocess.run(
        ["launchctl", "bootout", f"gui/{uid}/{agent.label}"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )

    proc = subprocess.run(
        ["launchctl", "bootstrap", f"gui/{uid}", str(agent.plist)],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )

    if proc.returncode == 0:
        return True, f"bootstrapped {agent.label}"

    return False, proc.stderr.strip() or f"failed to bootstrap {agent.label}"


def bootstrap_default_launch_agents(root: Path) -> list[str]:
    results: list[str] = []
    if platform.system() != "Darwin":
        return ["SKIP LaunchAgents unsupported on non-Darwin host"]
    for agent in default_launch_agents(root):
        ok, message = bootstrap_launch_agent(agent)
        prefix = "PASS" if ok else "SKIP"
        results.append(f"{prefix} {message}")
    return results


def bootout_default_launch_agents(root: Path, dry_run: bool = False) -> list[str]:
    results: list[str] = []
    if platform.system() != "Darwin":
        return ["SKIP LaunchAgents unsupported on non-Darwin host"]
    uid = os.getuid()

    for agent in default_launch_agents(root):
        if dry_run:
            results.append(f"DRY RUN would bootout gui/{uid}/{agent.label}")
            continue

        proc = subprocess.run(
            ["launchctl", "bootout", f"gui/{uid}/{agent.label}"],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )

        if proc.returncode == 0:
            results.append(f"booted out LaunchAgent {agent.label}")
        else:
            results.append(f"LaunchAgent {agent.label}: {proc.stderr.strip() or 'not loaded'}")

    return results
