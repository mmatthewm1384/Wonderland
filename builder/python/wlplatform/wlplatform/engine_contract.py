from __future__ import annotations

from dataclasses import dataclass, asdict
from pathlib import Path
from datetime import datetime, timezone


@dataclass
class EngineResult:

    engine: str
    action: str
    status: str
    details: dict | None = None

    def to_dict(self):
        return asdict(self)


class EngineContract:

    name = "unknown"

    def __init__(self, root: Path):
        self.root = Path(root)

    def verify(self):

        return EngineResult(
            engine=self.name,
            action="verify",
            status="NOT_IMPLEMENTED",
        )


    def status(self):

        return EngineResult(
            engine=self.name,
            action="status",
            status="NOT_IMPLEMENTED",
        )


    def certify(self):

        return EngineResult(
            engine=self.name,
            action="certify",
            status="NOT_IMPLEMENTED",
        )


    def artifact_path(self):

        return (
            self.root
            /
            "vault/08-Operations/certifications/normalized"
            /
            f"{self.name}-certification.json"
        )


    def write_artifact(
        self,
        result: EngineResult,
    ):

        path = self.artifact_path()

        path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        payload = result.to_dict()

        payload["timestamp"] = (
            datetime.now(timezone.utc)
            .isoformat()
        )

        path.write_text(
            __import__("json")
            .dumps(
                payload,
                indent=2,
            )
        )

        return path


    def metadata(self):

        return {
            "engine": self.name,
            "version": getattr(
                self,
                "version",
                "1.0.0"
            ),
            "owner": getattr(
                self,
                "owner",
                f"platform.{self.name}"
            ),
            "capabilities": getattr(
                self,
                "capabilities",
                []
            )
        }

