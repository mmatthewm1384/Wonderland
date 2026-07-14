#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OUT_ROOT = ROOT / "05-Vault/generated/handoffs"


def run(cmd: list[str]) -> tuple[int, str]:
    proc = subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return proc.returncode, proc.stdout.strip()


def latest_manifest_index() -> dict:
    path = ROOT / "05-Vault/generated/indexes/manifest-index.json"
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text())
    except Exception:
        return {}


def main() -> int:
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    handoff_id = f"platform-0.4-handoff-{stamp}"
    out_dir = OUT_ROOT / handoff_id
    out_dir.mkdir(parents=True, exist_ok=True)

    checks = {
        "platform_status": run(["bin/wl-platform-status"]),
        "engineering_gate": run(["bin/wl-engineering-gate"]),
        "manifest_index": run(["bin/wl-manifest-index"]),
        "git_branch": run(["git", "branch", "--show-current"]),
        "git_head": run(["git", "rev-parse", "--short", "HEAD"]),
        "git_status": run(["git", "status", "--short"]),
    }

    index = latest_manifest_index()

    failures = sum(
        1 for key, value in checks.items()
        if key not in {"git_status"} and value[0] != 0
    )

    md = []
    md.append("# Wonderland Platform 0.4 Handoff")
    md.append("")
    md.append(f"**Handoff ID:** `{handoff_id}`")
    md.append(f"**Created:** `{datetime.now(timezone.utc).isoformat()}`")
    md.append(f"**Status:** `{'PASS' if failures == 0 else 'FAIL'}`")
    md.append("**Destructive Changes:** `none`")
    md.append("")
    md.append("## Git")
    md.append("")
    md.append(f"- Branch: `{checks['git_branch'][1]}`")
    md.append(f"- HEAD: `{checks['git_head'][1]}`")
    md.append("")
    md.append("## Platform Checks")
    md.append("")
    for name in ["platform_status", "engineering_gate", "manifest_index"]:
        code, _ = checks[name]
        md.append(f"- {name}: `{'PASS' if code == 0 else 'FAIL'}`")
    md.append("")
    md.append("## Manifest Index")
    md.append("")
    md.append(f"- Manifest count: `{index.get('manifest_count', 0)}`")
    md.append("")
    md.append("## Current Platform Commands")
    md.append("")
    md.append("```bash")
    md.append("bin/wl-platform status")
    md.append("bin/wl-platform gate")
    md.append("bin/wl-platform certify")
    md.append("bin/wl-platform snapshot")
    md.append("bin/wl-platform manifests")
    md.append("```")
    md.append("")
    md.append("## Verification")
    md.append("")
    md.append("```bash")
    md.append("bin/wl-platform-status")
    md.append("bin/wl-engineering-gate")
    md.append("bin/wl-manifest-index")
    md.append("git status --short")
    md.append("```")
    md.append("")
    md.append("## Git Status")
    md.append("")
    md.append("```text")
    md.append(checks["git_status"][1])
    md.append("```")
    md.append("")

    handoff_path = out_dir / "HANDOFF.md"
    handoff_path.write_text("\n".join(md) + "\n")

    manifest = {
        "handoff_id": handoff_id,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "status": "PASS" if failures == 0 else "FAIL",
        "destructive_changes": False,
        "handoff": str(handoff_path.relative_to(ROOT)),
        "checks": {
            name: {
                "exit_code": code,
                "result": "PASS" if code == 0 else "FAIL",
                "output": output,
            }
            for name, (code, output) in checks.items()
        },
        "manifest_index_count": index.get("manifest_count", 0),
    }

    manifest_path = out_dir / "handoff-manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")

    print("Wonderland Platform Handoff")
    print()
    print(f"Handoff: {handoff_path.relative_to(ROOT)}")
    print(f"Manifest: {manifest_path.relative_to(ROOT)}")
    print(f"Status: {manifest['status']}")

    if failures:
        print("RESULT FAIL")
        return 1

    print("RESULT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
