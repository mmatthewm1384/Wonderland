from __future__ import annotations

import subprocess
from pathlib import Path


def _run(root: Path, script: str) -> int:
    p = subprocess.run([str(root / script)], cwd=root)
    return p.returncode


def certify(root: Path) -> int:
    return _run(root, "release/certify.py")


def manifest(root: Path) -> int:
    return _run(root, "release/manifest.py")


def package(root: Path) -> int:
    return _run(root, "release/package.py")


def verify(root: Path) -> int:
    return _run(root, "release/verify.py")


def build(root: Path) -> int:
    for fn in (certify, manifest, package, verify):
        rc = fn(root)
        if rc != 0:
            return rc
    return 0


def run(root: Path, action: str) -> int:
    actions = {
        "certify": certify,
        "manifest": manifest,
        "package": package,
        "verify": verify,
        "build": build,
    }
    return actions[action](root)
