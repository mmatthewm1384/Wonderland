from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path


WORKSPACE_DIR = Path(__file__).resolve().parent / "workspaces"


@dataclass(frozen=True)
class Workspace:
    name: str
    windows: list[str]
    description: str = ""


def load_workspaces() -> dict[str, Workspace]:
    workspaces: dict[str, Workspace] = {}

    for path in sorted(WORKSPACE_DIR.glob("*.json")):
        data = json.loads(path.read_text())
        name = str(data["name"])
        windows = [str(item) for item in data["windows"]]
        description = str(data.get("description", ""))

        if not windows:
            raise SystemExit(f"FAIL workspace has no windows: {path}")

        if windows[0] != "dashboard":
            raise SystemExit(f"FAIL workspace must start with dashboard: {path}")

        workspaces[name] = Workspace(name=name, windows=windows, description=description)

    if not workspaces:
        raise SystemExit(f"FAIL no workspaces found in {WORKSPACE_DIR}")

    return workspaces


def workspace_names() -> list[str]:
    return sorted(load_workspaces())


def get_workspace(name: str) -> Workspace:
    workspaces = load_workspaces()

    try:
        return workspaces[name]
    except KeyError:
        valid = ", ".join(sorted(workspaces))
        raise SystemExit(f"FAIL unknown workspace: {name}. Valid: {valid}")
