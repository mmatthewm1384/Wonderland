from __future__ import annotations

import json
from dataclasses import asdict, is_dataclass
from typing import Any


def _to_dict(obj: Any) -> Any:
    if hasattr(obj, "to_dict"):
        return obj.to_dict()
    if is_dataclass(obj):
        return asdict(obj)
    return obj


def render(result) -> int:
    payload = getattr(result, "payload", None)

    if payload is not None:
        print(json.dumps(payload, indent=2))
    else:
        print(json.dumps(_to_dict(result), indent=2))

    state = getattr(result, "state", "PASS")
    return 0 if state in ("PASS", "WARN") else 1
