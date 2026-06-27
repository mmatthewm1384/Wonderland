from __future__ import annotations

import subprocess
from pathlib import Path


def _run(root: Path, script: str) -> int:
    p = subprocess.run([str(root / script)], cwd=root)
    return p.returncode


def run(root: Path, action: str) -> int:
    scripts = {
        "create": "backup/create.py",
        "verify": "backup/verify.py",
        "preview": "backup/restore_preview.py",
        "restore-preview": "backup/restore_preview.py",
    }
    return _run(root, scripts[action])
