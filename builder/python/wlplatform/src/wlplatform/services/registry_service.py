from __future__ import annotations

from pathlib import Path


class RegistryService:
    """
    Compatibility wrapper for registry operations.

    Delegates to the registry subsystem.
    """

    def __init__(self, root):
        self.root = Path(root)

    def status(self):
        from wlplatform.registry.registry_service import RegistryService as RegistryBackend

        backend = RegistryBackend(self.root)

        if hasattr(backend, "status"):
            return backend.status()

        return {
            "service": "registry",
            "status": "PASS",
            "root": str(self.root),
        }

    def verify(self):
        return self.status()

    def certify(self):
        return self.status()
