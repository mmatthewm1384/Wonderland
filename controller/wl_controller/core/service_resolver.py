from __future__ import annotations

from pathlib import Path

from wl_controller.models.registry import ServiceRegistry
from wl_controller.policy.engine import PolicyEngine
from wl_controller.models.service import Service


class ServiceResolver:
    def __init__(self, root: Path | None = None):
        self.policy = PolicyEngine(root or Path.home() / "Wonderland")
    def resolve(
        self,
        services_json: dict,
        desired_json: dict,
        containers: list[dict],
        health: dict,
    ) -> ServiceRegistry:
        containers_by_name = {
            c.get("name"): c
            for c in containers
            if c.get("name")
        }

        health_by_name = health.get("services", {})

        names = self._service_names(services_json, desired_json, containers_by_name)

        services: list[Service] = []

        for name in sorted(names):
            container = containers_by_name.get(name, {})
            service_health = health_by_name.get(name, {})

            desired = self._desired(name, desired_json)
            policy = self.policy.service_policy(name)
            critical = bool(policy.get("critical", self._critical(name, services_json)))
            dependencies = list(policy.get("depends", self._dependencies(name, services_json)))

            running = bool(container.get("running"))
            healthy = bool(service_health.get("healthy", running))

            drift: list[str] = []
            if desired and not running:
                drift.append("desired_running_but_stopped")
            if desired and running and not healthy:
                drift.append("running_but_unhealthy")
            if not desired and running:
                drift.append("running_but_not_desired")

            services.append(
                Service(
                    name=name,
                    desired=desired,
                    running=running,
                    healthy=healthy,
                    critical=critical,
                    image=container.get("image", ""),
                    status=container.get("status", ""),
                    dependencies=dependencies,
                    health=service_health,
                    drift=drift,
                )
            )

        return ServiceRegistry(services=services)

    def _service_names(
        self,
        services_json: dict,
        desired_json: dict,
        containers_by_name: dict,
    ) -> set[str]:
        names: set[str] = set(containers_by_name.keys())

        for key in ("services", "items"):
            value = services_json.get(key)
            if isinstance(value, dict):
                names.update(value.keys())
            elif isinstance(value, list):
                for item in value:
                    if isinstance(item, str):
                        names.add(item)
                    elif isinstance(item, dict) and item.get("name"):
                        names.add(item["name"])

        for key in ("services", "desired", "containers"):
            value = desired_json.get(key)
            if isinstance(value, dict):
                names.update(value.keys())
            elif isinstance(value, list):
                for item in value:
                    if isinstance(item, str):
                        names.add(item)
                    elif isinstance(item, dict) and item.get("name"):
                        names.add(item["name"])

        return names

    def _desired(self, name: str, desired_json: dict) -> bool:
        for key in ("services", "desired", "containers"):
            value = desired_json.get(key)

            if isinstance(value, dict) and name in value:
                entry = value[name]
                if isinstance(entry, bool):
                    return entry
                if isinstance(entry, dict):
                    return bool(entry.get("enabled", entry.get("desired", True)))

            if isinstance(value, list):
                for item in value:
                    if item == name:
                        return True
                    if isinstance(item, dict) and item.get("name") == name:
                        return bool(item.get("enabled", item.get("desired", True)))

        return True

    def _critical(self, name: str, services_json: dict) -> bool:
        default_critical = {
            "wl-vaultwarden",
            "wl-vaultwarden-db",
            "wl-loki",
            "wl-prometheus",
            "wl-grafana",
            "wl-nats",
            "wl-dns",
        }

        for key in ("services", "items"):
            value = services_json.get(key)

            if isinstance(value, dict) and isinstance(value.get(name), dict):
                return bool(value[name].get("critical", name in default_critical))

            if isinstance(value, list):
                for item in value:
                    if isinstance(item, dict) and item.get("name") == name:
                        return bool(item.get("critical", name in default_critical))

        return name in default_critical

    def _dependencies(self, name: str, services_json: dict) -> list[str]:
        for key in ("services", "items"):
            value = services_json.get(key)

            if isinstance(value, dict) and isinstance(value.get(name), dict):
                deps = value[name].get("depends") or value[name].get("dependencies") or []
                return list(deps) if isinstance(deps, list) else []

            if isinstance(value, list):
                for item in value:
                    if isinstance(item, dict) and item.get("name") == name:
                        deps = item.get("depends") or item.get("dependencies") or []
                        return list(deps) if isinstance(deps, list) else []

        fallback = {
            "wl-grafana": ["wl-prometheus"],
            "wl-prometheus": ["wl-nats"],
            "wl-vaultwarden": ["wl-vaultwarden-db"],
        }

        return fallback.get(name, [])
