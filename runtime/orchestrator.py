from __future__ import annotations

import json
import time
from dataclasses import asdict, dataclass

from runtime.services import discover_services
from runtime.services.base import Service, state_dir


@dataclass
class StartupEvent:
    name: str
    status: str
    message: str = ""
    required: bool = True
    elapsed: float = 0.0


class RuntimeOrchestrator:
    def __init__(self, full: bool = False) -> None:
        self.full = full
        self.events: list[StartupEvent] = []

    def services(self) -> list[Service]:
        return self._dependency_order(discover_services(full=self.full))

    def _dependency_order(self, services: list[Service]) -> list[Service]:
        by_name = {service.name: service for service in services}
        ordered: list[Service] = []
        visiting: set[str] = set()
        visited: set[str] = set()

        def visit(service: Service) -> None:
            if service.name in visited:
                return
            if service.name in visiting:
                raise RuntimeError(f"cyclic runtime service dependency: {service.name}")

            visiting.add(service.name)

            for dependency in service.dependencies:
                if dependency in by_name:
                    visit(by_name[dependency])

            visiting.remove(service.name)
            visited.add(service.name)
            ordered.append(service)

        for service in services:
            visit(service)

        return ordered

    def emit(self, event: StartupEvent) -> StartupEvent:
        self.events.append(event)
        return event

    def write_graph_state(self, services: list[Service]) -> None:
        graph = {
            "full": self.full,
            "services": [service.metadata() for service in services],
            "edges": [
                {"from": dependency, "to": service.name}
                for service in services
                for dependency in service.dependencies
            ],
            "order": [service.name for service in services],
        }
        (state_dir() / "graph.json").write_text(json.dumps(graph, indent=2) + "\n")

    def write_service_state(self, services: list[Service]) -> None:
        service_state = {
            "full": self.full,
            "services": [service.metadata() for service in services],
        }
        (state_dir() / "services.json").write_text(json.dumps(service_state, indent=2) + "\n")

    def write_health_state(self, services: list[Service]) -> None:
        health = {
            "full": self.full,
            "services": {
                service.name: service.health().to_dict()
                for service in services
            },
        }
        (state_dir() / "health.json").write_text(json.dumps(health, indent=2) + "\n")

    def start(self):
        started_at = time.time()

        try:
            services = self.services()
            self.write_graph_state(services)
            self.write_service_state(services)
        except Exception as exc:
            yield self.emit(StartupEvent("startup-plan", "failed", str(exc), True, 0.0))
            return

        for service in services:
            step_started = time.time()
            yield self.emit(StartupEvent(service.name, "starting", "checking", service.required))

            health = service.health()
            healthy = health.healthy

            if not healthy:
                yield self.emit(StartupEvent(service.name, "starting", "starting", service.required))
                healthy = service.start()

            deadline = time.time() + service.timeout
            while not healthy and time.time() < deadline:
                time.sleep(0.5)
                healthy = service.health().healthy

            elapsed = time.time() - step_started

            if healthy:
                yield self.emit(StartupEvent(service.name, "ok", "ready", service.required, elapsed))
            elif service.required:
                yield self.emit(
                    StartupEvent(service.name, "failed", "required service failed", True, elapsed)
                )
                break
            else:
                yield self.emit(
                    StartupEvent(service.name, "warn", "optional service unavailable", False, elapsed)
                )

        total = time.time() - started_at
        failed = any(event.status == "failed" for event in self.events)

        self.write_health_state(services)

        report = {
            "ok": not failed,
            "elapsed": round(total, 3),
            "full": self.full,
            "events": [asdict(event) for event in self.events],
        }

        report_path = state_dir() / "startup.json"
        report_path.write_text(json.dumps(report, indent=2) + "\n")

        yield self.emit(
            StartupEvent(
                "ready" if not failed else "failed",
                "ok" if not failed else "failed",
                str(report_path),
                True,
                total,
            )
        )
