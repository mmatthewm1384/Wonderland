from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any
import sys

try:
    import yaml
except ImportError:  # pragma: no cover
    yaml = None


@dataclass(frozen=True)
class BuilderConfig:
    path: Path
    data: dict[str, Any]

    @property
    def default_profile(self) -> str:
        return str(self.data.get("default_profile", "development"))

    @property
    def output_root(self) -> Path:
        value = self.data.get("paths", {}).get("output_root", "builder/output")
        return self.repo_root / value

    @property
    def repo_root(self) -> Path:
        return self.path.resolve().parents[1]


def load_config(repo_root: Path) -> BuilderConfig:
    path = repo_root / "builder" / "config.yaml"

    if not path.is_file():
        raise FileNotFoundError(f"missing builder config: {path}")

    if yaml is None:
        raise RuntimeError("missing Python dependency: PyYAML")

    with path.open("r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle) or {}

    if not isinstance(data, dict):
        raise ValueError(f"invalid builder config: expected mapping in {path}")

    return BuilderConfig(path=path, data=data)
