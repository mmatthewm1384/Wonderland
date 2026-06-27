from __future__ import annotations

import subprocess
import time
from pathlib import Path


def git_revision(root: Path) -> str:
    p = subprocess.run(
        ["git", "rev-parse", "--short", "HEAD"],
        cwd=root,
        text=True,
        capture_output=True,
        check=False,
    )
    return p.stdout.strip() if p.returncode == 0 else "unknown"


def release_manifest(root: Path, version: str, schema: int, runtime: str) -> dict:
    return {
        "platform": "Wonderland",
        "version": version,
        "controller": version,
        "api": "v1",
        "schema": schema,
        "runtime": runtime,
        "git_revision": git_revision(root),
        "generated_at": time.time(),
    }
