#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
import time
from pathlib import Path


ROOT = Path.home() / "Wonderland"


def main() -> int:
    stamp = time.strftime("%Y%m%d-%H%M%S")
    out = ROOT / f"runtime/backups/wonderland-control-plane-{stamp}.tar.gz"

    includes = [
        "vault/05-Registry",
        "vault/08-Operations/state",
        "vault/09-Timeline",
        "runtime/events",
        "runtime/release",
        "schemas",
        "controller/wl_controller",
        "dashboard",
        "release",
        "backup",
        "docs",
        "bin/wl-controller-v2",
        "bin/wl-api-v2",
        "bin/wl-dashboard",
        "bin/wl-release",
        "bin/wl-platform-freeze",
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

    manifest = {
        "type": "wonderland-control-plane-backup",
        "generated_at": time.time(),
        "archive": str(out),
        "includes": existing,
    }

    latest = ROOT / "runtime/backups/wonderland-control-plane-latest.tar.gz"
    if latest.exists() or latest.is_symlink():
        latest.unlink()
    latest.symlink_to(out.name)

    meta = ROOT / "runtime/backups/backup-latest.json"
    meta.write_text(json.dumps(manifest, indent=2, sort_keys=True), encoding="utf-8")

    print(out)
    print(meta)
    print("RESULT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
