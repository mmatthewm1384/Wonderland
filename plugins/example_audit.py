from __future__ import annotations

import json
import time
from pathlib import Path


class ExampleAuditPlugin:
    name = "example-audit"

    def initialize(self, context):
        self.root = Path(context.root)
        self.log = self.root / "runtime/events/plugin-example-audit.jsonl"
        self.log.parent.mkdir(parents=True, exist_ok=True)

    def before_cycle(self):
        pass

    def after_cycle(self, state: dict):
        payload = {
            "ts": time.time(),
            "plugin": self.name,
            "status": state.get("certification", {}).get("status"),
            "drifted": state.get("registry", {}).get("resolved_services", {}).get("drifted"),
        }
        with self.log.open("a", encoding="utf-8") as f:
            f.write(json.dumps(payload, sort_keys=True) + "\n")

    def on_event(self, event: dict):
        pass


def plugin():
    return ExampleAuditPlugin()
