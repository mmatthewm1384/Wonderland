from __future__ import annotations


class RegistryService:
    def status(self) -> dict:
        return {
            "service": "registry",
            "status": "ready",
        }
