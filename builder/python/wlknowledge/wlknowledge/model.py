from __future__ import annotations

from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
import hashlib
import json
from typing import Any


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


@dataclass(frozen=True)
class Entity:
    name: str
    path: str
    kind: str
    metadata: dict[str, Any] = field(default_factory=dict)


@dataclass
class KnowledgeModel:
    system: str = "Wonderland Knowledge Engine"
    version: str = "0.1.0"
    stage: str = "model"
    generated_at: str = field(default_factory=utc_now)
    fingerprint: str = ""
    repository: dict[str, Any] = field(default_factory=dict)
    commands: list[Entity] = field(default_factory=list)
    applications: list[Entity] = field(default_factory=list)
    services: list[Entity] = field(default_factory=list)
    documents: list[Entity] = field(default_factory=list)
    decisions: list[Entity] = field(default_factory=list)

    @property
    def counts(self) -> dict[str, int]:
        return {
            "commands": len(self.commands),
            "applications": len(self.applications),
            "services": len(self.services),
            "documents": len(self.documents),
            "decisions": len(self.decisions),
        }

    def to_dict(self) -> dict[str, Any]:
        data = asdict(self)
        data["counts"] = self.counts
        if not data["fingerprint"]:
            data["fingerprint"] = self.compute_fingerprint(data)
        return data

    def compute_fingerprint(self, data: dict[str, Any] | None = None) -> str:
        payload = dict(data or asdict(self))
        payload.pop("fingerprint", None)
        raw = json.dumps(payload, sort_keys=True, separators=(",", ":"), default=str).encode()
        return hashlib.sha256(raw).hexdigest()[:16]

    def finalize(self) -> KnowledgeModel:
        self.fingerprint = self.compute_fingerprint()
        return self
