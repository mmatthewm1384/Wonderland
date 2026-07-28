from __future__ import annotations

"""
Wonderland Platform Maintenance Service.

Composition layer health verification.
Maintenance does not own capabilities.
It validates and reports platform service readiness.
"""

from typing import Any


class MaintenanceService:
    """
    Service health coordinator.

    Responsibilities:
    - import canonical services
    - execute health checks
    - return structured status
    - avoid owning domain logic
    """

    def _load_services(self) -> dict[str, Any]:
        from wlplatform.services import (
            PlatformService,
            RuntimeService,
            GovernanceService,
            RegistryService,
            TelemetryService,
        )

        return {
            "platform": PlatformService(),
            "runtime": RuntimeService(),
            "governance": GovernanceService(),
            "registry": RegistryService(),
            "telemetry": TelemetryService(),
        }

    def status(self) -> dict[str, Any]:
        services = self._load_services()

        components: dict[str, Any] = {}

        for name, service in services.items():
            try:
                if hasattr(service, "status"):
                    components[name] = service.status()
                else:
                    components[name] = {
                        "service": name,
                        "status": "loaded",
                    }

            except Exception as exc:
                components[name] = {
                    "service": name,
                    "status": "error",
                    "error": str(exc),
                }

        return {
            "service": "maintenance",
            "status": "ready",
            "components": components,
        }

    def doctor(self) -> dict[str, Any]:
        return {
            "operation": "doctor",
            **self.status(),
        }

    def verify(self) -> dict[str, Any]:
        return {
            "operation": "verify",
            **self.status(),
        }

    def repair(self) -> dict[str, Any]:
        return {
            "operation": "repair",
            "status": "not_required",
        }
