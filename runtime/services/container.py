from __future__ import annotations

from runtime.services.base import Service, nerdctl_in_wonderland


class ContainerdService(Service):
    def __init__(self) -> None:
        super().__init__(
            "containerd",
            required=False,
            timeout=30,
            dependencies=["wonderland-rootless"],
        )

    def check(self) -> bool:
        return nerdctl_in_wonderland()

    def start(self) -> bool:
        return nerdctl_in_wonderland()


class NerdctlService(Service):
    def __init__(self) -> None:
        super().__init__(
            "nerdctl",
            required=False,
            timeout=30,
            dependencies=["containerd"],
        )

    def check(self) -> bool:
        return nerdctl_in_wonderland()

    def start(self) -> bool:
        return nerdctl_in_wonderland()
