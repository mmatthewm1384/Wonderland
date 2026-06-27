from __future__ import annotations

import logging
import time
from pathlib import Path

from wl_controller.container.services import ServiceContainer
from wl_controller.core.recovery import RecoveryEngine
from wl_controller.core.state import PlatformState


class WonderlandController:
    def __init__(self, root: Path, services: ServiceContainer | None = None):
        self.root = root
        self.services = services or ServiceContainer(root)

        self.config = self.services.config()
        self.log = logging.getLogger("wonderland.controller")

        self.registry = self.services.registry()
        self.runtime = self.services.runtime()
        self.events = self.services.event_bus()
        self.timeline = self.services.timeline()
        self.events.subscribe(self.timeline)

        self.health = self.services.health()
        self.deploy_engine = self.services.deploy()
        self.policy_engine = self.services.policy()
        self.service_resolver = self.services.service_resolver()
        self.plugins = self.services.plugins()

        self.recovery_engine = RecoveryEngine(self.runtime)
        self.state_path = root / "vault/08-Operations/state/latest.json"
        self.state = PlatformState()

    def cycle(self) -> PlatformState:
        started = time.time()

        self.plugins.before_cycle()
        self.log.info(
            "controller cycle started",
            extra={"component": "controller", "event": "cycle.started"},
        )

        start_event = self.events.publish("controller.v3.cycle.started", {})
        self.plugins.on_event(
            {"ts": start_event.ts, "type": start_event.type, "payload": start_event.payload}
        )

        services_json = self.registry.services()
        desired = self.registry.desired_state()
        containers = self.runtime.to_dicts()

        recovery = self.recovery_engine.recover(containers)
        containers = self.runtime.to_dicts()

        health = self.health.check(containers)
        deploy = self.deploy_engine.deploy(desired)

        resolved_registry = self.service_resolver.resolve(
            services_json,
            desired,
            containers,
            health,
        )
        resolved_services = resolved_registry.to_dict()

        policy_state = self.policy_engine.validate_dependencies(
            set(resolved_registry.by_name().keys())
        )

        certification_status = (
            "PASS"
            if self.registry.valid()
            and self.runtime.lima_running()
            and policy_state.get("valid")
            else "FAIL"
        )

        self.state = PlatformState(
            schema=self.config.state_schema,
            runtime={
                "name": self.config.runtime,
                "running": self.runtime.lima_running(),
                "container_runtime": self.config.container_runtime,
                "legacy_default_supported": False,
            },
            registry={
                "valid": self.registry.valid(),
                "services_path": str(self.registry.services_file),
                "desired_state_path": str(self.registry.desired_file),
                "services": services_json,
                "resolved_services": resolved_services,
            },
            desired_state=desired,
            containers=containers,
            health=health,
            deployment=deploy,
            recovery=recovery,
            controller={
                "version": self.config.controller_version,
                "api_version": self.config.api_version,
                "cycle_duration_seconds": round(time.time() - started, 4),
                "authority": True,
                "service_container": self.services.status(),
            },
            timeline=self.timeline.status(),
            events=self.events.read_recent(100),
            certification={
                "status": certification_status,
            },
            metrics={
                "policy": policy_state,
                "plugins": self.plugins.status(),
            },
        )

        self.state.save(self.state_path)

        self.plugins.after_cycle(self.state.to_dict())

        self.log.info(
            "controller cycle finished",
            extra={
                "component": "controller",
                "event": "cycle.finished",
                "duration_seconds": self.state.controller["cycle_duration_seconds"],
                "status": self.state.certification["status"],
            },
        )

        finish_event = self.events.publish(
            "controller.v3.cycle.finished",
            {
                "duration_seconds": self.state.controller["cycle_duration_seconds"],
                "certification": self.state.certification["status"],
            },
        )
        self.plugins.on_event(
            {"ts": finish_event.ts, "type": finish_event.type, "payload": finish_event.payload}
        )

        self.state.events = self.events.read_recent(100)
        self.state.save(self.state_path)

        return self.state

    def snapshot(self) -> dict:
        return self.state.to_dict()

    def run_forever(self, interval: int = 30) -> None:
        started = self.events.publish("controller.v3.started", {})
        self.plugins.on_event(
            {"ts": started.ts, "type": started.type, "payload": started.payload}
        )

        try:
            while True:
                self.cycle()
                time.sleep(interval)
        finally:
            stopped = self.events.publish("controller.v3.stopped", {})
            self.plugins.on_event(
                {"ts": stopped.ts, "type": stopped.type, "payload": stopped.payload}
            )
