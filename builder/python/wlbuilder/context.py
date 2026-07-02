from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from wlbuilder.config import BuilderConfig


@dataclass(frozen=True)
class BuilderContext:
    repo_root: Path
    config: BuilderConfig
    profile: str
    output_root: Path
