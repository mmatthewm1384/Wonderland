from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from pathlib import Path


class HealthState(str, Enum):
    HEALTHY = "healthy"
    BUSY = "busy"
    WARNING = "warning"
    FAILED = "failed"
    OFFLINE = "offline"
    UNKNOWN = "unknown"


@dataclass(frozen=True)
class Health:
    name: str
    state: HealthState
    message: str = ""


@dataclass(frozen=True)
class Capability:
    name: str
    title: str
    shortcut: str
    window: str
    command: str
    health: Health


@dataclass(frozen=True)
class OperatorContext:
    root: Path
    state_dir: Path
    session: str = "wonderland"
