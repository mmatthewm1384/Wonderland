from __future__ import annotations

from wl.runtime.services.base import Service, pgrep


class RegistryService(Service):
    def __init__(self) -> None:
        super().__init__("registry", required=False, full_only=True)


class ObservabilityService(Service):
    def __init__(self) -> None:
        super().__init__("observability", required=False, full_only=True)


class GrafanaService(Service):
    def __init__(self) -> None:
        super().__init__(
            "grafana",
            required=False,
            full_only=True,
            dependencies=["observability"],
        )

    def check(self) -> bool:
        return pgrep("grafana")

    def start(self) -> bool:
        return False


class ControllerService(Service):
    def __init__(self) -> None:
        super().__init__("controller", required=False)


class ChaosService(Service):
    def __init__(self) -> None:
        super().__init__("chaos", required=False)


class MatrixService(Service):
    def __init__(self) -> None:
        super().__init__("matrix", required=False)


class ApplicationsService(Service):
    def __init__(self) -> None:
        super().__init__("applications", required=False)
