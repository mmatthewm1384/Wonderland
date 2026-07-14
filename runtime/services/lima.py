from __future__ import annotations

from runtime.services.base import Service, lima_running, start_lima


class WonderlandRootlessService(Service):
    def __init__(self) -> None:
        super().__init__("wonderland-rootless", required=False, timeout=120)

    def check(self) -> bool:
        return lima_running("wonderland-rootless")

    def start(self) -> bool:
        return start_lima("wonderland-rootless")


class WonderlandBuilderService(Service):
    def __init__(self) -> None:
        super().__init__("wonderland-os-builder", required=False, timeout=120)

    def check(self) -> bool:
        return lima_running("wonderland-os-builder")

    def start(self) -> bool:
        return start_lima("wonderland-os-builder")
