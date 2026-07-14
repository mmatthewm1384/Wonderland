from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class RuntimeState:
    state_dir: Path
    status: str = "ready"


def load_runtime_state(state_dir: Path | str = "state/runtime") -> RuntimeState:
    return RuntimeState(state_dir=Path(state_dir))


__all__ = ["RuntimeState", "load_runtime_state"]
