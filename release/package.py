#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import time
from pathlib import Path


ROOT = Path.home() / "Wonderland"


def main() -> int:
    stamp = time.strftime("%Y%m%d-%H%M%S")
    out = ROOT / f"runtime/release/wonderland-platform-{stamp}.tar.gz"

    includes = [
        "controller",
        "schemas",
        "release",
        "sdk",
        "bin/wl-control-center-package",
        "bin/wl-control-center",
        "runtime/apps/control-center",
        "apps/macos/wl-control-center",
        "bin/wl-controller-v2",
        "bin/wl-controller-core-v2",
        "bin/wl-api-v2",
        "bin/wl-status-v2",
        "runtime/release/certification-latest.json",
        "runtime/release/manifest-latest.json",
    ]

    existing = [p for p in includes if (ROOT / p).exists()]

    p = subprocess.run(
        ["tar", "-czf", str(out), *existing],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )

    if p.returncode != 0:
        print(p.stderr)
        return p.returncode

    latest = ROOT / "runtime/release/wonderland-platform-latest.tar.gz"
    if latest.exists() or latest.is_symlink():
        latest.unlink()
    latest.symlink_to(out.name)

    print(out)
    print(latest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
