from __future__ import annotations

import json
import os
import platform
import tempfile
import time
from pathlib import Path
from typing import Any


def repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def default_state_root() -> Path:
    env = os.environ.get("WONDERLAND_STATE_DIR")
    if env:
        return Path(env)

    if platform.system() == "Linux":
        return Path.home() / ".local" / "state" / "wonderland" / "runtime"

    return repo_root() / "state" / "runtime"


class RuntimeState:
    def __init__(self, root: Path | None = None) -> None:
        self.root = root or repo_root()
        self.dir = default_state_root()
        self.dir.mkdir(parents=True, exist_ok=True)

    def path(self, name: str) -> Path:
        return self.dir / name

    def write_json(self, name: str, data: dict[str, Any]) -> Path:
        path = self.path(name)
        payload = {
            "schema": f"wonderland.runtime.{name.removesuffix('.json')}.v1",
            "generated_at": time.time(),
            **data,
        }

        fd, tmp_name = tempfile.mkstemp(
            prefix=f".{name}.",
            suffix=".tmp",
            dir=str(self.dir),
            text=True,
        )

        try:
            with os.fdopen(fd, "w") as f:
                json.dump(payload, f, indent=2)
                f.write("\n")
            os.replace(tmp_name, path)
        finally:
            if os.path.exists(tmp_name):
                os.unlink(tmp_name)

        return path

    def read_json(self, name: str) -> dict[str, Any]:
        path = self.path(name)
        if not path.exists():
            return {}
        return json.loads(path.read_text())

    def write_startup(self, data: dict[str, Any]) -> Path:
        return self.write_json("startup.json", data)

    def write_health(self, data: dict[str, Any]) -> Path:
        return self.write_json("health.json", data)

    def write_services(self, data: dict[str, Any]) -> Path:
        return self.write_json("services.json", data)

    def write_graph(self, data: dict[str, Any]) -> Path:
        return self.write_json("graph.json", data)
