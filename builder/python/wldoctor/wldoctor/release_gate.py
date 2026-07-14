from __future__ import annotations

from pathlib import Path
from typing import Any

from .engine import DoctorEngine


class ReleaseGate:
    def __init__(self, root: Path) -> None:
        self.root = root.resolve()

    def evaluate(self) -> dict[str, Any]:
        doctor = DoctorEngine(
            self.root
        ).doctor()

        passed = (
            doctor["status"] == "PASS"
            and doctor["certified"]
        )

        return {
            "schema_version": 1,
            "engine": "release-gate",
            "result": (
                "PASS"
                if passed
                else "FAIL"
            ),
            "doctor_status": doctor["status"],
            "doctor_certified": doctor[
                "certified"
            ],
            "health_score": doctor[
                "health_score"
            ],
        }
