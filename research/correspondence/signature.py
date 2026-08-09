from __future__ import annotations
from dataclasses import asdict, dataclass
from typing import Any
import json

@dataclass(frozen=True)
class TransformationSignature:
    system_id: str
    source: str
    symmetry: dict[str, Any]
    polarity: dict[str, Any]
    feedback: dict[str, Any]
    boundary: dict[str, Any]
    dynamics: dict[str, Any]
    invariants: dict[str, Any]

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)

    def canonical_json(self) -> str:
        return json.dumps(self.to_dict(), sort_keys=True, separators=(",", ":"))
