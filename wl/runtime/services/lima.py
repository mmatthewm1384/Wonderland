from __future__ import annotations

from wl.runtime.host import is_linux
from wl.runtime.services.base import HealthResult, Service, lima_running, start_lima


class WonderlandRootlessService(Service):
    def __init__(self) -> None:
        super().__init__(
            "wonderland-rootless",
            description="Wonderland rootless runtime host.",
            required=False,
            timeout=5 if is_linux() else 120,
            dependencies=["secrets"],
            startup_priority=50,
        )

    def check(self) -> bool:
        if is_linux():
            return True
        return lima_running("wonderland-rootless")

    def start(self) -> bool:
        if is_linux():
            return True
        return start_lima("wonderland-rootless")

    def health(self) -> HealthResult:
        healthy = self.check()
        return HealthResult(
            healthy=healthy,
            status="running" if healthy else "stopped",
            message="linux runtime host" if is_linux() else (
                "wonderland-rootless running" if healthy else "wonderland-rootless unavailable"
            ),
        )


class WonderlandBuilderService(Service):
    def __init__(self) -> None:
        super().__init__(
            "wonderland-os-builder",
            description="Wonderland OS builder/runtime Linux environment.",
            required=False,
            timeout=5 if is_linux() else 120,
            dependencies=["secrets"],
            startup_priority=55,
        )

    def check(self) -> bool:
        if is_linux():
            return True
        return lima_running("wonderland-os-builder")

    def start(self) -> bool:
        if is_linux():
            return True
        return start_lima("wonderland-os-builder")

    def health(self) -> HealthResult:
        healthy = self.check()
        return HealthResult(
            healthy=healthy,
            status="running" if healthy else "stopped",
            message="current linux builder host" if is_linux() else (
                "wonderland-os-builder running" if healthy else "wonderland-os-builder unavailable"
            ),
        )
