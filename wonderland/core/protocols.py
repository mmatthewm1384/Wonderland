from typing import Protocol, runtime_checkable


@runtime_checkable
class ControlExecutor(Protocol):
    def spawn_service(self, service_name: str) -> bool:
        """Spawns a designated Wonderland service."""
        ...

    def terminate_service(self, service_name: str) -> bool:
        """Terminates a designated Wonderland service."""
        ...


@runtime_checkable
class AuditStore(Protocol):
    def log_event(self, subsystem: str, event_type: str, payload: dict) -> None:
        """Commits an immutable audit record to Crystal storage."""
        ...
