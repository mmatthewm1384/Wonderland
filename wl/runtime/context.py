from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class RuntimeContext:
    interactive: bool = True
    state_dir: Path | None = None
    theme: str = "default"

    def resolved_state_dir(self) -> Path:
        return self.state_dir or Path("state/runtime")
