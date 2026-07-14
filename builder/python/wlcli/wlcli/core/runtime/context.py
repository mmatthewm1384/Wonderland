from __future__ import annotations

import os
from dataclasses import asdict, dataclass
from pathlib import Path


@dataclass(frozen=True)
class RuntimeContext:
    root: Path
    log_dir: Path
    state_dir: Path
    runtime_instance: str
    profile: str
    channel: str = "local"
    version: str = "0.0.0"

    @classmethod
    def from_env(cls) -> "RuntimeContext":
        root = Path(os.environ.get("WL_HOME", Path.cwd())).resolve()
        return cls(
            root=root,
            log_dir=Path(os.environ.get("WL_LOG_DIR", "/tmp")),
            state_dir=root / "vault/08-Operations/state",
            runtime_instance=os.environ.get("WL_RUNTIME_INSTANCE", "wonderland-rootless"),
            profile=os.environ.get("WL_PROFILE", "default"),
            channel=os.environ.get("WL_CHANNEL", "local"),
            version=os.environ.get("WL_VERSION", "0.0.0"),
        )

    def env(self) -> dict[str, str]:
        env = os.environ.copy()
        env.setdefault("WL_HOME", str(self.root))
        env.setdefault("WL_LOG_DIR", str(self.log_dir))
        env.setdefault("WL_RUNTIME_INSTANCE", self.runtime_instance)
        env.setdefault("LIMA_INSTANCE", self.runtime_instance)
        env.setdefault("WL_PROFILE", self.profile)
        env.setdefault("WL_CHANNEL", self.channel)
        env.setdefault("WL_VERSION", self.version)
        return env

    def bin(self, name: str) -> Path:
        return self.root / "bin" / name

    def state_file(self, name: str) -> Path:
        return self.state_dir / name

    def to_dict(self) -> dict:
        data = asdict(self)
        for key in ("root", "log_dir", "state_dir"):
            data[key] = str(data[key])
        return data
