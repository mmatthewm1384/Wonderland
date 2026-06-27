#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


WL_HOME = Path(os.environ.get("WL_HOME", str(Path.home() / "Wonderland")))
INTERVAL = int(os.environ.get("WL_CONTROLLER_INTERVAL", "30"))


@dataclass
class Step:
    name: str
    command: list[str]


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def run(step: Step) -> dict:
    started = time.time()
    proc = subprocess.run(
        step.command,
        cwd=WL_HOME,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    return {
        "name": step.name,
        "command": step.command,
        "returncode": proc.returncode,
        "duration_seconds": round(time.time() - started, 3),
        "ok": proc.returncode == 0,
        "output": proc.stdout,
    }


def emit(event: str, **fields: str) -> None:
    cmd = [str(WL_HOME / "bin/wl-event"), event]
    cmd.extend(f"{k}={v}" for k, v in fields.items())
    subprocess.run(cmd, cwd=WL_HOME, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def cycle() -> int:
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    report_dir = WL_HOME / "vault/08-Operations/reports/controller"
    report_dir.mkdir(parents=True, exist_ok=True)

    report = report_dir / f"controller-core-{stamp}.json"
    latest = report_dir / "latest-core.json"

    emit("controller.core.cycle.started", stamp=stamp)

    steps = [
        Step("refresh", [str(WL_HOME / "bin/wl-services-refresh")]),
        Step("reconcile", [str(WL_HOME / "bin/wl-reconcile")]),
        Step("recover", [str(WL_HOME / "bin/wl-services-recover")]),
        Step("health", [str(WL_HOME / "bin/wl-services-health")]),
        Step("certify", [str(WL_HOME / "bin/wl-certify-platform-services")]),
        Step("timeline", [str(WL_HOME / "bin/wl-timeline"), "sync"]),
        Step("state", [str(WL_HOME / "bin/wl-state")]),
        Step("status", [str(WL_HOME / "bin/wl-platform-status")]),
    ]

    started = time.time()
    results = [run(step) for step in steps]
    ok = all(r["ok"] for r in results)

    doc = {
        "generated_at": now(),
        "controller": "wl-controller-core",
        "result": "PASS" if ok else "FAIL",
        "duration_seconds": round(time.time() - started, 3),
        "steps": results,
    }

    report.write_text(json.dumps(doc, indent=2) + "\n")
    latest.write_text(json.dumps(doc, indent=2) + "\n")

    emit(
        "controller.core.cycle.finished" if ok else "controller.core.cycle.failed",
        result=doc["result"],
        report=str(report),
        duration=str(doc["duration_seconds"]),
    )

    print(f"RESULT {doc['result']} controller core")
    print(f"REPORT {report}")

    return 0 if ok else 1


def main() -> int:
    once = "--once" in sys.argv

    emit("controller.core.started", interval=str(INTERVAL))

    while True:
        rc = cycle()

        if once:
            emit("controller.core.stopped")
            return rc

        time.sleep(INTERVAL)


if __name__ == "__main__":
    raise SystemExit(main())
