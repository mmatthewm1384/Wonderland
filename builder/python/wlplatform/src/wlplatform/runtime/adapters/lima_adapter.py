from __future__ import annotations

from pathlib import Path


class LimaRuntimeAdapter:
    """
    Runtime boundary adapter for Lima.

    Uses lazy imports to avoid service package circular imports.
    """

    def __init__(
        self,
        root: Path,
        vm_name: str = "wonderland-rootless",
    ):
        self.root = Path(root)
        self.vm_name = vm_name

    @property
    def service(self):
        from wlplatform.services.lima_service import LimaService

        return LimaService(
            self.root,
            vm_name=self.vm_name,
        )

    def verify(self):
        return self.service.run_checks()

    def certify(self):
        return self.service.run_checks()

    def start(self):
        return self.service.ensure_running()

    def status(self):
        return self.service.report()


# Compatibility name expected by runtime_service.py
LimaAdapter = LimaRuntimeAdapter
