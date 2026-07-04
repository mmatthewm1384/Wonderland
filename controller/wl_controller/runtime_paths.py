from __future__ import annotations

from pathlib import Path


def runtime_root(root: Path) -> Path:
    return root / "runtime"


def controller_runtime(root: Path) -> Path:
    return runtime_root(root) / "controller"


def chaos_runtime(root: Path) -> Path:
    return runtime_root(root) / "chaos"


def controller_latest(root: Path) -> Path:
    return controller_runtime(root) / "latest.json"


def chaos_scheduler_audit(root: Path) -> Path:
    return chaos_runtime(root) / "scheduler-audit.jsonl"


def ensure_runtime_dirs(root: Path) -> None:
    controller_runtime(root).mkdir(parents=True, exist_ok=True)
    chaos_runtime(root).mkdir(parents=True, exist_ok=True)
