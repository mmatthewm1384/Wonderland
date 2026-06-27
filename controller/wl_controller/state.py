#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import subprocess
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


WL_HOME = Path(os.environ.get("WL_HOME", str(Path.home() / "Wonderland")))
REGISTRY = WL_HOME / "vault/05-Registry/services.json"
DESIRED = WL_HOME / "vault/05-Registry/desired-state.json"
EVENTS = WL_HOME / "runtime/events/events.jsonl"
TIMELINE_INDEX = WL_HOME / "vault/09-Timeline/index.json"
DEPLOYMENT_LATEST = WL_HOME / "vault/08-Operations/deployments/latest.json"
RECOVERY_LATEST = WL_HOME / "vault/08-Operations/reports/recovery/latest.json"
CONTROLLER_LATEST = WL_HOME / "vault/08-Operations/reports/controller/latest-core.json"
STATE_DIR = WL_HOME / "vault/08-Operations/state"


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def read_json(path: Path) -> dict[str, Any] | None:
    try:
        if path.exists():
            return json.loads(path.read_text())
    except Exception as e:
        return {"error": str(e), "path": str(path)}
    return None


def run(cmd: list[str]) -> tuple[int, str]:
    proc = subprocess.run(
        cmd,
        cwd=WL_HOME,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return proc.returncode, proc.stdout


def runtime_state() -> dict[str, Any]:
    rc, out = run(["limactl", "list"])
    running = "wonderland-rootless" in out and "Running" in out
    return {
        "runtime": "wonderland-rootless",
        "running": running,
        "limactl_returncode": rc,
    }


def container_state() -> list[dict[str, Any]]:
    rc, out = run([
        "bash",
        "-lc",
        "LIMA_INSTANCE=wonderland-rootless nerdctl ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'",
    ])

    containers: list[dict[str, Any]] = []
    for line in out.splitlines():
        parts = line.split("\t")
        if len(parts) >= 4:
            name, image, status, ports = parts[:4]
            containers.append({
                "name": name,
                "image": image,
                "status": status,
                "ports": ports,
                "up": "Up" in status,
            })

    return containers


def count_events() -> int:
    try:
        if EVENTS.exists():
            return sum(1 for _ in EVENTS.open())
    except Exception:
        return 0
    return 0


def build_state() -> dict[str, Any]:
    registry = read_json(REGISTRY)
    desired = read_json(DESIRED)
    deployment = read_json(DEPLOYMENT_LATEST)
    recovery = read_json(RECOVERY_LATEST)
    controller = read_json(CONTROLLER_LATEST)
    timeline = read_json(TIMELINE_INDEX)

    containers = container_state()
    up_count = sum(1 for c in containers if c.get("up"))

    services = registry.get("services", []) if isinstance(registry, dict) else []
    service_count = len(services)

    return {
        "generated_at": now(),
        "runtime": runtime_state(),
        "registry": {
            "path": str(REGISTRY),
            "valid": registry.get("valid") if isinstance(registry, dict) else False,
            "service_count": service_count,
            "start_order": registry.get("start_order") if isinstance(registry, dict) else [],
        },
        "desired": {
            "path": str(DESIRED),
            "present": DESIRED.exists(),
            "service_count": len(desired.get("services", {})) if isinstance(desired, dict) else 0,
        },
        "containers": {
            "total": len(containers),
            "up": up_count,
            "items": containers,
        },
        "deployment": deployment,
        "recovery": recovery,
        "controller": controller,
        "events": {
            "path": str(EVENTS),
            "count": count_events(),
        },
        "timeline": timeline,
        "healthy": (
            bool(registry and registry.get("valid"))
            and bool(runtime_state().get("running"))
            and service_count > 0
            and up_count >= service_count
        ),
    }


def write_state() -> Path:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out = STATE_DIR / f"platform-state-{stamp}.json"
    latest = STATE_DIR / "latest.json"

    state = build_state()
    out.write_text(json.dumps(state, indent=2) + "\n")
    latest.write_text(json.dumps(state, indent=2) + "\n")
    return out


def main() -> int:
    out = write_state()
    print(f"STATE {out}")

    latest = STATE_DIR / "latest.json"
    state = json.loads(latest.read_text())

    print(f"RUNTIME wonderland-rootless running={state['runtime']['running']}")
    print(f"REGISTRY valid={state['registry']['valid']} services={state['registry']['service_count']}")
    print(f"CONTAINERS up={state['containers']['up']} total={state['containers']['total']}")
    print(f"EVENTS count={state['events']['count']}")
    print("RESULT PASS" if state["healthy"] else "RESULT WARN")

    return 0 if state["healthy"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
