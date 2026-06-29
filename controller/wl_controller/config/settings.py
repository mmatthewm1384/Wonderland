from __future__ import annotations

import json
import os
from dataclasses import asdict, dataclass
from pathlib import Path


@dataclass(frozen=True)
class ControllerConfig:
    root: Path
    runtime: str
    container_runtime: str
    api_host: str
    api_port: int
    api_version: str
    dashboard_host: str
    dashboard_port: int
    reconcile_interval: int
    state_schema: int
    controller_version: str

    @classmethod
    def load(cls, root: Path) -> "ControllerConfig":
        path = root / "config/wonderland.json"

        data: dict = {}
        if path.exists():
            data = json.loads(path.read_text(encoding="utf-8"))

        runtime = data.get("runtime", {})
        api = data.get("api", {})
        dashboard = data.get("dashboard", {})
        scheduler = data.get("scheduler", {})
        controller = data.get("controller", {})

        return cls(
            root=root,
            runtime=os.environ.get("WONDERLAND_RUNTIME", runtime.get("lima_instance", "wonderland-rootless")),
            container_runtime=os.environ.get("WONDERLAND_CONTAINER_RUNTIME", runtime.get("container_runtime", "nerdctl")),
            api_host=os.environ.get("WONDERLAND_API_HOST", api.get("host", "127.0.0.1")),
            api_port=int(os.environ.get("WONDERLAND_API_PORT", api.get("port", 9105))),
            api_version=os.environ.get("WONDERLAND_API_VERSION", api.get("version", "v1")),
            dashboard_host=os.environ.get("WONDERLAND_DASHBOARD_HOST", dashboard.get("host", "127.0.0.1")),
            dashboard_port=int(os.environ.get("WONDERLAND_DASHBOARD_PORT", dashboard.get("port", 9110))),
            reconcile_interval=int(os.environ.get("WONDERLAND_RECONCILE_INTERVAL", scheduler.get("reconcile_interval", 30))),
            state_schema=int(os.environ.get("WONDERLAND_STATE_SCHEMA", controller.get("state_schema", 1))),
            controller_version=os.environ.get("WONDERLAND_CONTROLLER_VERSION", controller.get("version", "3.0.0")),
        )

    def to_dict(self) -> dict:
        data = asdict(self)
        data["root"] = str(self.root)
        return data
