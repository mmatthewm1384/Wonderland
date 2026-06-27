from __future__ import annotations

from pathlib import Path
from typing import Any

from wl_controller.config.settings import ControllerConfig
from wl_controller.core.deploy import DeployEngine
from wl_controller.core.registry import Registry
from wl_controller.core.service_resolver import ServiceResolver
from wl_controller.events.bus import EventBus
from wl_controller.events.timeline import TimelineWriter
from wl_controller.health.engine import HealthEngine
from wl_controller.policy.engine import PolicyEngine
from wl_controller.plugins.null import NullPluginManager
from wl_controller.runtime.containers import ContainerRuntime


class ServiceContainer:
    def __init__(self, root: Path):
        self.root = root
        self._instances: dict[str, Any] = {}

    def _get(self, key: str, factory):
        if key not in self._instances:
            self._instances[key] = factory()
        return self._instances[key]

    def config(self) -> ControllerConfig:
        return self._get("config", lambda: ControllerConfig.load(self.root))

    def registry(self) -> Registry:
        return self._get("registry", lambda: Registry(self.root))

    def runtime(self) -> ContainerRuntime:
        return self._get("runtime", lambda: ContainerRuntime(self.config().runtime))

    def event_bus(self) -> EventBus:
        return self._get(
            "event_bus",
            lambda: EventBus(self.root / "runtime/events/events.jsonl"),
        )

    def timeline(self) -> TimelineWriter:
        return self._get(
            "timeline",
            lambda: TimelineWriter(self.root / "vault/09-Timeline"),
        )

    def health(self) -> HealthEngine:
        return self._get("health", HealthEngine)

    def deploy(self) -> DeployEngine:
        return self._get("deploy", DeployEngine)

    def policy(self) -> PolicyEngine:
        return self._get("policy", lambda: PolicyEngine(self.root))

    def service_resolver(self) -> ServiceResolver:
        return self._get("service_resolver", lambda: ServiceResolver(self.root))

    def plugins(self):
        def factory():
            try:
                from wl_controller.plugins.manager import PluginManager

                manager = PluginManager(self.root, self.config().controller_version)
                manager.discover()
                return manager
            except Exception as e:
                return NullPluginManager(str(e))

        return self._get("plugins", factory)

    def status(self) -> dict:
        return {
            "root": str(self.root),
            "services": sorted(self._instances.keys()),
        }
