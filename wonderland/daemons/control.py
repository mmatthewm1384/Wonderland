from typing import Any


class ControlDaemonService:
    def __init__(self, executor: Any, audit_store: Any) -> None:
        self.executor = executor
        self.audit_store = audit_store

    def handle_service_lifecycle(self, service_name: str, action: str) -> None:
        if action == "start":
            success = self.executor.spawn_service(service_name)
            status = "SUCCESS" if success else "FAILED"
            self.audit_store.log_event(
                service_name, "START", {"service": service_name, "status": status}
            )
        elif action == "stop":
            success = self.executor.terminate_service(service_name)
            status = "SUCCESS" if success else "FAILED"
            self.audit_store.log_event(
                service_name, "STOP", {"service": service_name, "status": status}
            )
        else:
            self.audit_store.log_event(
                service_name,
                "UNKNOWN",
                {"service": service_name, "status": "FAILED", "action": action},
            )

    def run_safely(self, command: str) -> bool:
        try:
            self.executor.execute(command)
            return True
        except Exception:
            return False
