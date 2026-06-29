from __future__ import annotations

import json
import threading
import time
from wl_controller.kernel.scheduler import Scheduler
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from wl_controller.config.settings import ControllerConfig
from wl_controller.config.version import release_manifest
from wl_controller.core.controller import WonderlandController
from wl_controller.metrics.exporter import MetricsExporter
from wl_controller.validation.schema import SchemaValidator


class APIServer:
    def __init__(
        self,
        root: Path,
        host: str = "127.0.0.1",
        port: int = 9105,
        interval: int = 30,
    ):
        self.root = root
        self.host = host
        self.port = port
        self.interval = interval
        self.controller = WonderlandController(root)
        self.metrics = MetricsExporter()
        self.schema_validator = SchemaValidator(root)
        self.config = ControllerConfig.load(root)
        self._lock = threading.Lock()
        self._state = self.controller.cycle().to_dict()
        self.scheduler = Scheduler()
        self.scheduler.add("reconcile", float(self.interval), self._scheduled_cycle)

    def _set_state(self, state: dict) -> None:
        with self._lock:
            self._state = state

    def _get_state(self) -> dict:
        with self._lock:
            return dict(self._state)

    def _scheduled_cycle(self) -> None:
        state = self.controller.cycle().to_dict()
        state.setdefault("kernel", {})
        state["kernel"]["scheduler"] = self.scheduler.status()
        self._set_state(state)

    def _loop(self) -> None:
        while True:
            self.scheduler.tick()
            current = self._get_state()
            current.setdefault("kernel", {})
            current["kernel"]["scheduler"] = self.scheduler.status()
            self._set_state(current)
            time.sleep(1)

    def serve(self) -> None:
        threading.Thread(target=self._loop, daemon=True).start()

        api = self
        metrics = self.metrics

        class Handler(BaseHTTPRequestHandler):
            def _json(self, data: dict, status: int = 200):
                body = json.dumps(data, indent=2, sort_keys=True).encode()
                self.send_response(status)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)

            def _text(self, body: str, status: int = 200, content_type: str = "text/plain"):
                data = body.encode()
                self.send_response(status)
                self.send_header("Content-Type", content_type)
                self.send_header("Content-Length", str(len(data)))
                self.end_headers()
                self.wfile.write(data)

            def do_GET(self):
                state = api._get_state()
                route = self.path
                aliases = {
                    "/api/v1/status": "/status",
                    "/api/v1/state": "/state",
                    "/api/v1/services": "/services",
                    "/api/v1/events": "/events",
                    "/api/v1/timeline": "/timeline",
                    "/api/v1/ready": "/ready",
                    "/api/v1/drift": "/drift",
                    "/api/v1/metrics": "/metrics",
                    "/api/v1/schema": "/schema",
                    "/api/v1/config": "/config",
                    "/api/v1/openapi.json": "/openapi.json",
                    "/api/v1/stream": "/stream",
                    "/api/v1/plugins": "/plugins",
                }
                route = aliases.get(route, route)

                if route == "/stream":
                    self.send_response(200)
                    self.send_header("Content-Type", "text/event-stream")
                    self.send_header("Cache-Control", "no-cache")
                    self.send_header("Connection", "keep-alive")
                    self.end_headers()

                    last_generated = None

                    try:
                        while True:
                            state = api._get_state()
                            generated = state.get("generated_at")

                            if generated != last_generated:
                                payload = {
                                    "type": "state",
                                    "generated_at": generated,
                                    "status": state.get("certification", {}).get("status"),
                                    "ready": (
                                        state.get("certification", {}).get("status") == "PASS"
                                        and bool(state.get("runtime", {}).get("running"))
                                        and state.get("registry", {}).get("resolved_services", {}).get("drifted", 0) == 0
                                    ),
                                    "services": state.get("registry", {}).get("resolved_services", {}),
                                    "controller": state.get("controller", {}),
                                }
                                body = "event: state\n" + "data: " + json.dumps(payload, sort_keys=True) + "\n\n"
                                self.wfile.write(body.encode())
                                self.wfile.flush()
                                last_generated = generated

                            time.sleep(1)
                    except Exception:
                        return

                elif route == "/openapi.json":
                    spec = api.root / "docs/api/openapi.json"
                    if spec.exists():
                        self._json(json.loads(spec.read_text(encoding="utf-8")))
                    else:
                        self._json({"error": "openapi spec missing"}, 404)
                elif route == "/api/v1/version" or route == "/version":
                    self._json(release_manifest(
                        api.root,
                        str(state.get("controller", {}).get("version", "unknown")),
                        int(state.get("schema", 1)),
                        str(state.get("runtime", {}).get("name", "unknown")),
                    ))
                elif route == "/status":
                    self._json({
                        "status": state.get("certification", {}).get("status"),
                        "runtime": state.get("runtime", {}),
                        "health": state.get("health", {}),
                        "controller": state.get("controller", {}),
                    })
                elif route == "/state":
                    self._json(state)
                elif route == "/services":
                    self._json(state.get("registry", {}).get("services", {}))
                elif route == "/events":
                    self._json({"events": state.get("events", [])})
                elif route == "/timeline":
                    self._json(state.get("timeline", {}))
                elif route == "/ready":
                    resolved = state.get("registry", {}).get("resolved_services", {})
                    ready = (
                        state.get("certification", {}).get("status") == "PASS"
                        and bool(state.get("runtime", {}).get("running"))
                        and resolved.get("drifted", 0) == 0
                    )
                    self._json({
                        "ready": ready,
                        "status": state.get("certification", {}).get("status"),
                        "runtime_running": bool(state.get("runtime", {}).get("running")),
                        "services_ready": resolved.get("ready", 0),
                        "services_total": resolved.get("total", 0),
                        "drifted": resolved.get("drifted", 0),
                        "schema": state.get("schema"),
                        "controller": state.get("controller", {}),
                    })
                elif route == "/plugins":
                    self._json(state.get("metrics", {}).get("plugins", {}))
                elif route == "/config":
                    self._json(api.config.to_dict())
                elif route == "/schema":
                    self._json(api.schema_validator.validate_platform())
                elif route == "/drift":
                    resolved = state.get("registry", {}).get("resolved_services", {})
                    services = resolved.get("services", [])
                    drifted = [svc for svc in services if svc.get("drift")]
                    self._json({
                        "drifted": len(drifted),
                        "services": drifted,
                    })
                elif route == "/metrics":
                    self._text(metrics.render(state))
                else:
                    self._json({"error": "not found"}, 404)

            def do_POST(self):
                if self.path in {
                    "/refresh",
                    "/state/snapshot",
                    "/reconcile",
                    "/recover",
                    "/deploy",
                    "/certify",
                }:
                    state = api.controller.cycle().to_dict()
                    api._set_state(state)
                    self._json({"ok": True, "state": state})
                else:
                    self._json({"error": "not found"}, 404)

            def log_message(self, fmt, *args):
                return

        server = ThreadingHTTPServer((self.host, self.port), Handler)
        print(f"Wonderland Controller v2.1 API listening on http://{self.host}:{self.port}")
        server.serve_forever()
