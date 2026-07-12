from __future__ import annotations

import os
import subprocess
from dataclasses import dataclass
from pathlib import Path


class MirrorContextError(RuntimeError):
    pass


@dataclass(frozen=True, slots=True)
class MirrorContext:
    root: Path

    @classmethod
    def discover(cls) -> "MirrorContext":
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

        raise MirrorContextError(
            "unable to locate Wonderland repository root"
        )

    @property
    def operations_root(self) -> Path:
        return self.root / "vault/08-Operations"

    @property
    def state_root(self) -> Path:
        return self.operations_root / "state"

    @property
    def certification_root(self) -> Path:
        return self.operations_root / "certifications/mirror"

    def environment(self) -> dict[str, str]:
        env = os.environ.copy()
        env["WL_HOME"] = str(self.root)
        env["WONDERLAND_ROOT"] = str(self.root)
        env["WL_MIRROR_NONINTERACTIVE"] = "1"
        env["WL_NONINTERACTIVE"] = "1"
        env["CI"] = env.get("CI", "1")
        return env
