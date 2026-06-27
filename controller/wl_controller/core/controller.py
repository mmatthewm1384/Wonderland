from __future__ import annotations

import logging
import time
from pathlib import Path

from wl_controller.config.settings import ControllerConfig
from wl_controller.core.deploy import DeployEngine
from wl_controller.core.recovery import RecoveryEngine
from wl_controller.core.registry import Registry
from wl_controller.core.state import PlatformState
from wl_controller.events.bus import EventBus
from wl_controller.events.timeline import TimelineWriter
from wl_controller.health.engine import HealthEngine
from wl_controller.runtime.containers import ContainerRuntime
from wl_controller.policy.engine import PolicyEngine
try:
    from wl_controller.plugins.manager import PluginManager
except Exception as e:
    PluginManager = None
    _PLUGIN_IMPORT_ERROR = str(e)

from wl_controller.plugins.null import NullPluginManager
from wl_controller.core.service_resolver import ServiceResolver


class WonderlandController:
    def __init__(self, root: Path):
        self.root = root
        self.config = ControllerConfig.load(root)
        self.log = logging.getLogger("wonderland.controller")
        self.registry = Registry(root)
        self.runtime = ContainerRuntime(self.config.runtime)
        self.events = EventBus(root / "runtime/events/events.jsonl")
        self.timeline = TimelineWriter(root / "vault/09-Timeline")
        self.events.subscribe(self.timeline)
        self.health = HealthEngine()
        self.deploy_engine = DeployEngine()
        self.recovery_engine = RecoveryEngine(self.runtime)
        self.service_resolver = ServiceResolver(root)
        self.policy_engine = PolicyEngine(root)
        if PluginManager is not None:
            self.plugins = PluginManager(root, self.config.controller_version)
            self.plugins.discover()
        else:
            self.plugins = NullPluginManager(_PLUGIN_IMPORT_ERROR)
        self.state_path = root / "vault/08-Operations/state/latest.json"
        self.state = PlatformState()

    def cycle(self) -> PlatformState:
        started = time.time()
        self.plugins.before_cycle()
        self.log.info("controller cycle started", extra={"component": "controller", "event": "cycle.started"})
        start_event = self.events.publish("controller.v3.cycle.started", {})
        self.plugins.on_event({"ts": start_event.ts, "type": start_event.type, "payload": start_event.payload})

        services = self.registry.services()
        desired = self.registry.desired_state()
        containers = self.runtime.to_dicts()

        recovery = self.recovery_engine.recover(containers)
        containers = self.runtime.to_dicts()

        health = self.health.check(containers)
        deploy = self.deploy_engine.deploy(desired)
        resolved_registry = self.service_resolver.resolve(services, desired, containers, health)
        resolved_services = resolved_registry.to_dict()
        policy_state = self.policy_engine.validate_dependencies(set(resolved_registry.by_name().keys()))

        self.state = PlatformState(
            schema=self.config.state_schema,
            runtime={
                "name": self.config.runtime,
                "running": self.runtime.lima_running(),
                "container_runtime": "nerdctl",
                "legacy_default_supported": False,
            },
            desired_state=desired,
            containers=containers,
            health=health,
            deployment=deploy,
            registry={
                "valid": self.registry.valid(),
                "services_path": str(self.registry.services_file),
                "desired_state_path": str(self.registry.desired_file),
                "services": services,
                "resolved_services": resolved_services,
            },
            recovery=recovery,
            controller={
                "version": self.config.controller_version,
                "api_version": "v3",
                "cycle_duration_seconds": round(time.time() - started, 4),
                "authority": True,
            },
            timeline=self.timeline.status(),
            events=self.events.read_recent(100),
            certification={
                "status": "PASS" if self.registry.valid() and self.runtime.lima_running() and policy_state.get("valid") else "FAIL"
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
        finish_event = self.events.publish("controller.v3.cycle.finished", {
            "duration_seconds": self.state.controller["cycle_duration_seconds"],
            "certification": self.state.certification["status"],
        })
        self.plugins.on_event({"ts": finish_event.ts, "type": finish_event.type, "payload": finish_event.payload})

        self.state.events = self.events.read_recent(100)
        self.state.save(self.state_path)

        return self.state

    def snapshot(self) -> dict:
        return self.state.to_dict()

    def run_forever(self, interval: int = 30) -> None:
        self.events.publish("controller.v3.started", {})
        try:
            while True:
                self.cycle()
                time.sleep(interval)
        finally:
            self.events.publish("controller.v3.stopped", {})
