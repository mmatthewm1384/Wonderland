#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OUT_ROOT = ROOT / "05-Vault/generated/snapshots"


FILES = [
    "01-Platform/registry/repository-layout.json",
    "01-Platform/registry/repository-ownership.json",
    "01-Platform/registry/repository-rules.json",
    "01-Platform/registry/repository-aliases.json",
    "01-Platform/registry/repository-classification.json",
    "01-Platform/registry/builder-ownership.json",
    "01-Platform/registry/service.py",
    "01-Platform/registry/consumer.py",
    "01-Platform/architecture/engine.py",
    "01-Platform/certification/engineering-gate.sh",
    "01-Platform/certification/platform-certify.py",
    "01-Platform/release/preflight.py",
    "01-Platform/release/manifest-index.py",
]


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def run(cmd: list[str]) -> dict[str, object]:
    proc = subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return {
        "command": cmd,
        "exit_code": proc.returncode,
        "result": "PASS" if proc.returncode == 0 else "FAIL",
        "output": proc.stdout,
    }


def main() -> int:
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    snapshot_id = f"platform-0.4-snapshot-{stamp}"
    out_dir = OUT_ROOT / snapshot_id
    out_dir.mkdir(parents=True, exist_ok=True)

    files = []
    for rel in FILES:
        path = ROOT / rel
        files.append({
            "path": rel,
            "exists": path.exists(),
            "sha256": sha256(path) if path.exists() else None,
        })

    checks = {
        "platform_status": run(["bin/wl-platform-status"]),
        "engineering_gate": run(["bin/wl-engineering-gate"]),
        "manifest_index": run(["bin/wl-manifest-index"]),
        "git_status": run(["git", "status", "--short"]),
        "git_branch": run(["git", "branch", "--show-current"]),
        "git_head": run(["git", "rev-parse", "--short", "HEAD"]),
    }

    failures = sum(
        1
        for name, result in checks.items()
        if name not in {"git_status"} and result["exit_code"] != 0
    )

    manifest = {
        "snapshot_id": snapshot_id,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "platform": "Wonderland",
        "platform_version": "0.4",
        "status": "PASS" if failures == 0 else "FAIL",
        "destructive_changes": False,
        "files": files,
        "checks": checks,
    }

    path = out_dir / "platform-snapshot.json"
    path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")

    print("Wonderland Platform Snapshot")
    print()
    print(f"Snapshot: {snapshot_id}")
    print(f"Manifest: {path.relative_to(ROOT)}")
    print(f"Files: {len(files)}")
    print(f"Status: {manifest['status']}")

    if failures:
        print(f"RESULT FAIL")
        return 1

    print("RESULT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
