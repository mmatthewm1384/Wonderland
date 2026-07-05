from __future__ import annotations

from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
import hashlib
import json


@dataclass
class Entity:
    name: str
    path: str
    type: str = "file"


@dataclass
class KnowledgeModel:
    system: str = "Wonderland Knowledge Engine"
    version: str = "0.1.0"
    stage: str = "python-compiler"
    generated_at: str = field(default_factory=lambda: datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
    fingerprint: str = ""
    repository: dict[str, Any] = field(default_factory=dict)
    counts: dict[str, int] = field(default_factory=dict)
    commands: list[Entity] = field(default_factory=list)
    applications: list[Entity] = field(default_factory=list)
    services: list[Entity] = field(default_factory=list)
    documents: list[Entity] = field(default_factory=list)
    decisions: list[Entity] = field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        data = asdict(self)
        if not data.get("fingerprint"):
            data["fingerprint"] = self.compute_fingerprint(data)
        return data

    def compute_fingerprint(self, data: dict[str, Any] | None = None) -> str:
        payload = dict(data or asdict(self))
        payload.pop("fingerprint", None)
        raw = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
        return hashlib.sha256(raw).hexdigest()[:16]

    def finalize(self) -> "KnowledgeModel":
        self.counts = {
            "commands": len(self.commands),
            "applications": len(self.applications),
            "services": len(self.services),
            "documents": len(self.documents),
            "decisions": len(self.decisions),
        }
        self.fingerprint = self.compute_fingerprint()
        return self
