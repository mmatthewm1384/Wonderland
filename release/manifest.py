#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import subprocess
import time
from pathlib import Path


ROOT = Path.home() / "Wonderland"


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def git_revision() -> str:
    p = subprocess.run(
        ["git", "rev-parse", "--short", "HEAD"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    return p.stdout.strip() if p.returncode == 0 else "unknown"


def api_version() -> dict:
    p = subprocess.run(
        ["curl", "-fsS", "http://127.0.0.1:9105/api/v1/version"],
        text=True,
        capture_output=True,
        check=False,
    )
    if p.returncode != 0:
        return {}
    try:
        return json.loads(p.stdout)
    except json.JSONDecodeError:
        return {}


def main() -> int:
    certification = ROOT / "runtime/release/certification-latest.json"

    manifest = {
        "platform": "Wonderland",
        "type": "release-manifest",
        "generated_at": time.time(),
        "git_revision": git_revision(),
        "api_version": api_version(),
        "artifacts": {},
    }

    if certification.exists():
        manifest["artifacts"]["certification"] = {
            "path": str(certification),
            "sha256": sha256_file(certification),
        }

    for rel in [
        "controller/wl_controller",
        "schemas",
        "bin/wl-controller-v2",
        "bin/wl-api-v2",
        "bin/wl-status-v2",
        "bin/wl-controller-core-v2",
    ]:
        path = ROOT / rel
        if path.exists() and path.is_file():
            manifest["artifacts"][rel] = {
                "path": str(path),
                "sha256": sha256_file(path),
            }

    out = ROOT / "runtime/release/manifest-latest.json"
    out.write_text(json.dumps(manifest, indent=2, sort_keys=True), encoding="utf-8")
    print(json.dumps(manifest, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
