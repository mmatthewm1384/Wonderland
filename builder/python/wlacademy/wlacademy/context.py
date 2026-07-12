from __future__ import annotations

import os
import subprocess
from dataclasses import dataclass
from pathlib import Path


class AcademyContextError(RuntimeError):
    pass


@dataclass(frozen=True, slots=True)
class AcademyContext:
    root: Path

    @classmethod
    def discover(cls) -> "AcademyContext":
        configured = (
            os.environ.get("WL_HOME")
            or os.environ.get("WONDERLAND_ROOT")
        )

        if configured:
            candidate = Path(configured).expanduser().resolve()

            if (candidate / ".git").exists():
                return cls(candidate)

        candidate = Path(__file__).resolve().parents[4]

        if (candidate / ".git").exists():
            return cls(candidate)

        completed = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            check=False,
        )

        if completed.returncode == 0 and completed.stdout.strip():
            candidate = Path(
                completed.stdout.strip()
            ).resolve()

            if (candidate / ".git").exists():
                return cls(candidate)

        raise AcademyContextError(
            "unable to locate Wonderland repository root"
        )

    @property
    def academy_root(self) -> Path:
        return self.root / "academy"

    @property
    def operations_root(self) -> Path:
        return self.root / "vault/08-Operations"

    @property
    def certification_root(self) -> Path:
        return self.operations_root / "certifications/academy"

    def environment(self) -> dict[str, str]:
        env = os.environ.copy()
        env["WL_HOME"] = str(self.root)
        env["WONDERLAND_ROOT"] = str(self.root)
        env["WL_ACADEMY_NONINTERACTIVE"] = "1"
        env["WL_NONINTERACTIVE"] = "1"
        env["CI"] = env.get("CI", "1")
        return env
