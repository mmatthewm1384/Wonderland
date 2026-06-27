#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
import sys
import time
from pathlib import Path


ROOT = Path.home() / "Wonderland"
API = "http://127.0.0.1:9105"


def run(cmd: list[str]) -> dict:
    p = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True, check=False)
    return {
        "command": cmd,
        "returncode": p.returncode,
        "stdout": p.stdout.strip(),
        "stderr": p.stderr.strip(),
        "ok": p.returncode == 0,
    }


def curl_json(path: str) -> dict:
    p = subprocess.run(
        ["curl", "-fsS", f"{API}{path}"],
        text=True,
        capture_output=True,
        check=False,
    )
    if p.returncode != 0:
        return {"ok": False, "error": p.stderr.strip(), "path": path}

    try:
        data = json.loads(p.stdout)
    except json.JSONDecodeError as e:
        return {"ok": False, "error": str(e), "path": path, "raw": p.stdout}

    data["_ok"] = True
    return data


def main() -> int:
    checks = {
        "compile": run(["python3", "-m", "compileall", "controller/wl_controller"]),
        "ready": curl_json("/api/v1/ready"),
        "version": curl_json("/api/v1/version"),
        "state": curl_json("/api/v1/state"),
        "drift": curl_json("/api/v1/drift"),
        "metrics": run(["curl", "-fsS", f"{API}/api/v1/metrics"]),
    }

    ready = checks["ready"].get("ready") is True
    drifted = checks["drift"].get("drifted") == 0
    compile_ok = checks["compile"]["ok"]
    metrics_ok = checks["metrics"]["ok"]
    state_ok = checks["state"].get("certification", {}).get("status") == "PASS"

    status = "PASS" if all([ready, drifted, compile_ok, metrics_ok, state_ok]) else "FAIL"

    report = {
        "platform": "Wonderland",
        "type": "release-certification",
        "status": status,
        "generated_at": time.time(),
        "checks": checks,
    }

    out = ROOT / "runtime/release/certification-latest.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2, sort_keys=True), encoding="utf-8")

    print(json.dumps(report, indent=2, sort_keys=True))
    return 0 if status == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
