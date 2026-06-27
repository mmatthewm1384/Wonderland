from __future__ import annotations

import json
from pathlib import Path

from wl_controller.policy.engine import PolicyEngine


def run(root: Path) -> int:
    result = PolicyEngine(root).load()
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0 if result.get("valid") else 1
