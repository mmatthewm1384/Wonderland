from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class ControllerConfig:
    root: Path
    runtime: str = "wonderland-rootless"
    api_host: str = "127.0.0.1"
    api_port: int = 9105
    reconcile_interval: int = 30
    state_schema: int = 1
    controller_version: str = "3.0.0"

    @classmethod
    def load(cls, root: Path) -> "ControllerConfig":
        return cls(
            root=root,
            runtime=os.environ.get("WONDERLAND_RUNTIME", "wonderland-rootless"),
            api_host=os.environ.get("WONDERLAND_API_HOST", "127.0.0.1"),
            api_port=int(os.environ.get("WONDERLAND_API_PORT", "9105")),
            reconcile_interval=int(os.environ.get("WONDERLAND_RECONCILE_INTERVAL", "30")),
            controller_version=os.environ.get("WONDERLAND_CONTROLLER_VERSION", "3.0.0"),
        )
