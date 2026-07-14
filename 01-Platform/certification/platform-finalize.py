#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OUT_ROOT = ROOT / "05-Vault/generated/platform-bundles"


CHECKS = [
    ("registry", ["bin/wl-registry", "verify"]),
    ("architecture_gate", ["python3", "01-Platform/architecture/engine.py", "gate", "--root", str(ROOT)]),
    ("builder_ownership", ["bin/wl-builder-ownership"]),
    ("platform_snapshot", ["bin/wl-platform-snapshot"]),
    ("platform_handoff", ["bin/wl-platform-handoff"]),
    ("manifest_index", ["bin/wl-manifest-index"]),
    ("manifest_index", ["bin/wl-manifest-index"]),
    ("engineering_gate", ["bin/wl-engineering-gate"]),
]


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


def git(cmd: list[str]) -> str:
    proc = subprocess.run(
        ["git", *cmd],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return proc.stdout.strip()


def main() -> int:
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    bundle_id = f"platform-0.4-final-bundle-{stamp}"
    out_dir = OUT_ROOT / bundle_id
    out_dir.mkdir(parents=True, exist_ok=True)

    checks = {}
    failures = 0

    print("Wonderland Platform 0.4 Final Bundle")
    print()

    for name, cmd in CHECKS:
        result = run(cmd)
        checks[name] = result
        print(f"{name}: {result['result']}")
        if result["exit_code"] != 0:
            failures += 1

    manifest = {
        "bundle_id": bundle_id,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "platform": "Wonderland",
        "platform_version": "0.4",
        "status": "PASS" if failures == 0 else "FAIL",
        "destructive_changes": False,
        "git": {
            "branch": git(["branch", "--show-current"]),
            "head": git(["rev-parse", "--short", "HEAD"]),
            "status_short": git(["status", "--short"]),
        },
        "checks": checks,
    }

    manifest_path = out_dir / "platform-final-bundle.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")

    summary_path = ROOT / f"vault/08-Operations/certifications/{bundle_id}.md"
    summary_path.write_text(
        "\n".join([
            "# Wonderland Platform 0.4 Final Bundle",
            "",
            f"Bundle ID: `{bundle_id}`",
            f"Status: `{'PASS' if failures == 0 else 'FAIL'}`",
            "Destructive changes: `none`",
            "",
            f"Manifest: `{manifest_path.relative_to(ROOT)}`",
            "",
            "## Checks",
            "",
            *[f"- {name}: `{item['result']}`" for name, item in checks.items()],
            "",
        ]) + "\n"
    )

    print()
    print(f"Manifest: {manifest_path.relative_to(ROOT)}")
    print(f"Summary: {summary_path.relative_to(ROOT)}")

    if failures:
        print(f"FAIL final bundle: {failures} failure(s)")
        print("RESULT FAIL")
        return 1

    print("PASS final bundle")
    print("RESULT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
