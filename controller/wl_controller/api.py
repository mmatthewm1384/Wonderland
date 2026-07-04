#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import subprocess
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse


WL_HOME = Path(os.environ.get("WL_HOME", str(Path.home() / "Wonderland")))
HOST = os.environ.get("WL_API_HOST", "127.0.0.1")
PORT = int(os.environ.get("WL_API_PORT", "9105"))

STATE = WL_HOME / "runtime/controller/latest.json"
REGISTRY = WL_HOME / "vault/05-Registry/services.json"
EVENTS = WL_HOME / "runtime/events/events.jsonl"
TIMELINE = WL_HOME / "vault/09-Timeline/timeline.jsonl"


def run(cmd: list[str]) -> tuple[int, str]:
    proc = subprocess.run(
        cmd,
        cwd=WL_HOME,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return proc.returncode, proc.stdout


def read_json(path: Path):
    if not path.exists():
        return {"error": "missing", "path": str(path)}
    try:
        return json.loads(path.read_text())
    except Exception as e:
        return {"error": str(e), "path": str(path)}


def read_jsonl_tail(path: Path, n: int = 50):
    if not path.exists():
        return []
    lines = path.read_text(errors="replace").splitlines()[-n:]
    out = []
    for line in lines:
        try:
            out.append(json.loads(line))
        except Exception:
            out.append({"raw": line})
    return out


def metrics_text() -> str:
    state = read_json(STATE)
    registry = read_json(REGISTRY)

    runtime_running = 1 if state.get("runtime", {}).get("running") else 0
    registry_valid = 1 if registry.get("valid") else 0
    service_count = int(state.get("registry", {}).get("service_count") or 0)
    containers_up = int(state.get("containers", {}).get("up") or 0)
    containers_total = int(state.get("containers", {}).get("total") or 0)
    events_count = int(state.get("events", {}).get("count") or 0)

    return "\n".join([
        "# HELP wonderland_runtime_running Runtime running state.",
        "# TYPE wonderland_runtime_running gauge",
        f"wonderland_runtime_running {runtime_running}",
        "# HELP wonderland_registry_valid Service registry validity.",
        "# TYPE wonderland_registry_valid gauge",
        f"wonderland_registry_valid {registry_valid}",
        "# HELP wonderland_services_total Number of registered services.",
        "# TYPE wonderland_services_total gauge",
        f"wonderland_services_total {service_count}",
        "# HELP wonderland_containers_up Number of running containers.",
        "# TYPE wonderland_containers_up gauge",
        f"wonderland_containers_up {containers_up}",
        "# HELP wonderland_containers_total Number of known containers.",
        "# TYPE wonderland_containers_total gauge",
        f"wonderland_containers_total {containers_total}",
        "# HELP wonderland_events_total Number of local events.",
        "# TYPE wonderland_events_total counter",
        f"wonderland_events_total {events_count}",
        "",
    ])


class Handler(BaseHTTPRequestHandler):
    server_version = "WonderlandControllerAPI/1.0"

    def log_message(self, fmt, *args):
        return

    def send_json(self, data, status: int = 200):
        body = json.dumps(data, indent=2).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def send_text(self, text: str, content_type: str = "text/plain; version=0.0.4"):
        body = text.encode()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


    def do_POST(self):
        if self.path == "/chaos/model":
            try:
                length = int(self.headers.get("Content-Length", "0"))
                raw = self.rfile.read(length).decode("utf-8") if length else "{}"
                payload = json.loads(raw or "{}")
                body, status = handle_chaos_model(payload)
                self.send_json(body, status)
            except Exception as exc:
                self.send_json({"ok": False, "status": "error", "message": str(exc)}, 500)
            return

        path = urlparse(self.path).path

        actions = {
            "/reconcile": [str(WL_HOME / "bin/wl-reconcile")],
            "/recover": [str(WL_HOME / "bin/wl-services-recover")],
            "/deploy": [str(WL_HOME / "bin/wl-services-deploy")],
            "/certify": [str(WL_HOME / "bin/wl-certify-platform-services")],
            "/refresh": [str(WL_HOME / "bin/wl-services-refresh")],
            "/timeline/sync": [str(WL_HOME / "bin/wl-timeline"), "sync"],
            "/state/snapshot": [str(WL_HOME / "bin/wl-state")],
        }

        cmd = actions.get(path)

        if not cmd:
            self.send_json({
                "error": "not found",
                "routes": sorted(actions.keys())
            }, 404)
            return

        rc, out = run(cmd)

        self.send_json({
            "ok": rc == 0,
            "returncode": rc,
            "command": cmd,
            "output": out,
        }, 200 if rc == 0 else 500)

    def do_GET(self):
        path = urlparse(self.path).path

        if path == "/status":
            rc, out = run([str(WL_HOME / "bin/wl-platform-status")])
            self.send_json({
                "ok": rc == 0,
                "returncode": rc,
                "output": out,
            }, 200 if rc == 0 else 503)
            return

        if path == "/state":
            run([str(WL_HOME / "bin/wl-state")])
            self.send_json(read_json(STATE))
            return

        if path == "/services":
            self.send_json(read_json(REGISTRY))
            return

        if path == "/events":
            self.send_json({
                "events": read_jsonl_tail(EVENTS, 100)
            })
            return

        if path == "/timeline":
            self.send_json({
                "timeline": read_jsonl_tail(TIMELINE, 100)
            })
            return

        if path == "/metrics":
            self.send_text(metrics_text())
            return

        self.send_json({
            "error": "not found",
            "routes": [
                "GET /status",
                "GET /state",
                "GET /services",
                "GET /events",
                "GET /timeline",
                "GET /metrics"
            ]
        }, 404)



CHAOS_MODELS = {
    "calm": {"command": "status", "risk_level": 0},
    "nudge": {"command": "checkin", "risk_level": 1},
    "drift": {"command": "panic", "risk_level": 2},
    "storm": {"command": "panic", "risk_level": 3},
    "blackout": {"command": "panic", "risk_level": 4},
    "cataclysm": {"command": "panic", "risk_level": 5},
    "recovery": {"command": "reset", "risk_level": 0},
}

def handle_chaos_model(payload):
    import json
    import subprocess
    from datetime import datetime, timezone
    from pathlib import Path

    root = Path.home() / "Wonderland"
    audit = root / "vault/chaos/controller-chaos-audit.jsonl"

    model = str(payload.get("model", "")).strip()
    requested_command = str(payload.get("command", "")).strip()

    if model not in CHAOS_MODELS:
        return {
            "ok": False,
            "status": "denied",
            "message": f"unknown chaos model: {model}",
        }, 400

    spec = CHAOS_MODELS[model]
    command = spec["command"]

    if requested_command and requested_command != command:
        return {
            "ok": False,
            "status": "denied",
            "message": f"command mismatch: expected {command}, got {requested_command}",
        }, 400

    event = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "event": "controller_chaos_model",
        "model": model,
        "command": command,
        "risk_level": spec["risk_level"],
    }

    audit.parent.mkdir(parents=True, exist_ok=True)
    with audit.open("a", encoding="utf-8") as f:
        f.write(json.dumps(event, sort_keys=True) + "\n")

    result = subprocess.run(
        [str(root / "bin/wl-chaos"), command],
        text=True,
        capture_output=True,
        timeout=15,
    )

    if result.returncode != 0:
        return {
            "ok": False,
            "status": "failed",
            "message": result.stderr.strip() or result.stdout.strip() or "chaos command failed",
        }, 500

    return {
        "ok": True,
        "status": "executed",
        "model": model,
        "command": command,
        "risk_level": spec["risk_level"],
        "message": result.stdout.strip(),
    }, 200

def main() -> int:
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"Wonderland Controller API listening on http://{HOST}:{PORT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nWonderland Controller API stopped")
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
