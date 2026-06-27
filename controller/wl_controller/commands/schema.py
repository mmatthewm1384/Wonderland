from __future__ import annotations

import json
from pathlib import Path

from wl_controller.validation.schema import SchemaValidator


def run(root: Path) -> int:
    result = SchemaValidator(root).validate_platform()
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0 if result.get("valid") else 1
