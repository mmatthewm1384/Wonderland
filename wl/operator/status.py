from __future__ import annotations

import json
import subprocess
from pathlib import Path
from typing import Any

from wl.operator.core import OperatorContext
from wl.operator.registry import discover
from wl.operator.workspace import workspace_names


SESSION = "wonderland"


def git_summary(root: Path) -> dict[str, Any]:
    def out(cmd: str) -> str:
        return subprocess.getoutput(cmd).strip()

    return {
        "branch": out("git branch --show-current 2>/dev/null || true") or "unknown",
        "changed_files": int(out("git status --short 2>/dev/null | wc -l | tr -d ' '") or "0"),
    }


def build_status(root: Path) -> dict[str, Any]:
    context = OperatorContext(root=root, state_dir=root / "state" / "operator", session=SESSION)
    capabilities = discover(context)

    return {
        "version": "1.0",
        "name": "operator",
        "session": SESSION,
        "root": str(root),
        "backend": "tmux",
        "git": git_summary(root),
        "capabilities": [
            {
                "name": cap.name,
                "title": cap.title,
                "window": cap.window,
                "shortcut": cap.shortcut,
                "command": cap.command,
                "health": {
                    "name": cap.health.name,
                    "state": cap.health.state.value,
                    "message": cap.health.message,
                },
            }
            for cap in capabilities
        ],
        "workspaces": workspace_names(),
    }


def write_status(root: Path) -> Path:
    path = root / "state" / "operator" / "status.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(build_status(root), indent=2, sort_keys=True) + "\n")
    return path
