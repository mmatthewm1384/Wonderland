from __future__ import annotations

import json
from pathlib import Path

from wl_controller.config.settings import ControllerConfig


def run(root: Path) -> int:
    config = ControllerConfig.load(root)
    print(json.dumps(config.to_dict(), indent=2, sort_keys=True))
    return 0
