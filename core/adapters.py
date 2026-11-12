import json
import os


class CrystalAuditStore:
    def __init__(self, log_path: str = "crystal_audit.log"):
        self.log_path = log_path

    def log_event(self, service: str, event: str, payload: dict) -> None:
        record = {"service": service.upper(), "event": event.upper(), "payload": payload}
        with open(self.log_path, "a") as f:
            f.write(json.dumps(record) + "\n")

    def get_entries(self) -> list:
        if not os.path.exists(self.log_path):
            return []
        entries = []
        with open(self.log_path) as f:
            for line in f:
                if line.strip():
                    try:
                        entries.append(json.loads(line))
                    except json.JSONDecodeError:
                        pass
        return entries
