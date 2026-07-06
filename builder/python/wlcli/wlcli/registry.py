from __future__ import annotations

from dataclasses import asdict, dataclass
from pathlib import Path
import json
import os


@dataclass(frozen=True)
class Command:
    name: str
    category: str
    description: str
    target: str | None = None


def discover(root: Path) -> list[Command]:
    commands = [
        Command("start", "Runtime", "Start Wonderland through the Boot Graph"),
        Command("stop", "Runtime", "Stop Wonderland through the Boot Graph"),
        Command("status", "Runtime", "Show runtime and service status"),
        Command("graph", "Runtime", "Show the START Boot Graph"),
        Command("graph-json", "Runtime", "Show the START Boot Graph as JSON"),
        Command("doctor", "Engineering", "Verify CLI and runtime prerequisites"),
        Command("self-test", "Engineering", "Verify wlcli lifecycle routing"),
        Command("palette", "Interface", "Show Wonderland color palette"),
        Command("commands", "Engineering", "Show command registry table"),
        Command("commands-json", "Engineering", "Show command registry as JSON"),
        Command("boot-report", "Runtime", "Show the last Boot Graph report"),
        Command("services", "Runtime", "Manage Wonderland services", "wl-services"),
        Command("rootless", "Runtime", "Manage Wonderland rootless runtime", "wl-rootless"),
        Command("apps", "Applications", "Manage Wonderland graphical app lifecycle", "wl-apps"),
    ]

    candidates = {
        "browser": ("Applications", "Manage browser policy, profiles, and verification", "wl-browser"),
        "academy": ("Knowledge", "Manage Wonderland Academy", "wl-academy"),
        "knowledge": ("Knowledge", "Manage Wonderland knowledge pipeline", "wlknowledge"),
        "mirror": ("Storage", "Manage Wonderland T7 mirror", "wl-mirror"),
        "storage": ("Storage", "Manage attach/eject/storage authority", "wl-storage"),
        "verify": ("Engineering", "Run platform verification", "wl-verify"),
        "certify": ("Engineering", "Run platform certification", "wl-certify"),
        "checkpoint": ("Engineering", "Create or manage checkpoints", "wl-checkpoint"),
    }

    for name, (category, description, target) in candidates.items():
        path = root / "bin" / target
        if path.exists() and os.access(path, os.X_OK):
            commands.append(Command(name, category, description, target))

    return sorted(commands, key=lambda c: (c.category, c.name))


def command_map(root: Path) -> dict[str, Command]:
    return {cmd.name: cmd for cmd in discover(root)}


def print_help(root: Path) -> None:
    commands = discover(root)

    current = None
    print("Wonderland CLI\n")
    print("Usage:")
    print("  wl <command> [args...]\n")
    print("Commands:")

    for cmd in commands:
        if cmd.category != current:
            current = cmd.category
            print(f"\n  {current}")
        print(f"    {cmd.name:<12} {cmd.description}")



def print_commands(root: Path) -> None:
    commands = discover(root)
    print("Wonderland Command Registry\n")
    for cmd in commands:
        target = cmd.target or "wlcli"
        print(f"{cmd.category:<14} {cmd.name:<14} {target:<20} {cmd.description}")


def print_commands_json(root: Path) -> None:
    print(json.dumps([asdict(cmd) for cmd in discover(root)], indent=2))
