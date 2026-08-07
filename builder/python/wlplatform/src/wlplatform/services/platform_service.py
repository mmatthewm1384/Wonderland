from __future__ import annotations

from pathlib import Path
from datetime import UTC, datetime


class PlatformService:

    def __init__(self, root):
        self.root = Path(root)

    def _result(self, action):
        return {
            "service": "platform",
            "action": action,
            "status": "PASS",
            "timestamp": datetime.now(UTC).isoformat(),
            "root": str(self.root),
        }

    def start(self):
        return self._result("start")

    def stop(self):
        return self._result("stop")

    def restart(self):
        return self._result("restart")

    def sleep(self):
        return self._result("sleep")

    def wake(self):
        return self._result("wake")

    def status(self):
        return self._result("status")
