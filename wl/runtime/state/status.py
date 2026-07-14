from __future__ import annotations

import json
import os
import platform
import time
from pathlib import Path
from typing import Any


def wonderland_root() -> Path:
    return Path(
        os.environ.get("WONDERLAND_ROOT")
        or os.environ.get("WL_HOME")
        or Path.cwd()
    ).resolve()


def status_path(root: Path | None = None) -> Path:
    root = root or wonderland_root()
    return root / "state/runtime/startup.json"


def write_startup_status(
    *,
    elapsed_ms: int,
    mode: str,
    theme: str,
    animation: str,
    stages: list[dict[str, Any]],
) -> Path:
    root = wonderland_root()
    path = status_path(root)
    path.parent.mkdir(parents=True, exist_ok=True)

    payload = {
        "schema": "wonderland.runtime.startup.v1",
        "status": "ready",
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "elapsed_ms": elapsed_ms,
        "mode": mode,
        "theme": theme,
        "animation": animation,
        "host": platform.node(),
        "platform": platform.platform(),
        "stages": stages,
    }

    tmp = path.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(payload, indent=2) + "\n")
    tmp.replace(path)
    return path
