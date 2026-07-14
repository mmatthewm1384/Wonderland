#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OUT_ROOT = ROOT / "05-Vault/generated/certifications"


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
    certification_id = f"platform-0.4-certification-preflight-{stamp}"
    out_dir = OUT_ROOT / certification_id
    out_dir.mkdir(parents=True, exist_ok=True)

    checks = {
        "registry": run(["bin/wl-registry", "verify"]),
        "architecture_gate": run(["python3", "01-Platform/architecture/engine.py", "gate", "--root", str(ROOT)]),
        "builder_ownership": run(["bin/wl-builder-ownership"]),
        "engineering_gate": run(["bin/wl-engineering-gate"]),
        "release_preflight": run(["bin/wl-release-preflight"]),
    }

    failures = sum(1 for item in checks.values() if item["exit_code"] != 0)

    manifest = {
        "certification_id": certification_id,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "status": "PASS" if failures == 0 else "FAIL",
        "mode": "preflight",
        "destructive_changes": False,
        "checks": checks,
    }

    manifest_path = out_dir / "certification-manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")

    print("Wonderland Certification Preflight")
    print()
    for name, item in checks.items():
        print(f"{name}: {item['result']}")

    print()
    print(f"Manifest: {manifest_path.relative_to(ROOT)}")

    if failures:
        print(f"FAIL certification preflight: {failures} failure(s)")
        print("RESULT FAIL")
        return 1

    print("PASS certification preflight")
    print("RESULT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
