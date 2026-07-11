from __future__ import annotations

import os
import subprocess
from dataclasses import dataclass
from pathlib import Path


class PlatformContextError(RuntimeError):
    pass


@dataclass(frozen=True, slots=True)
class PlatformContext:
    root: Path

    @classmethod
    def discover(cls) -> "PlatformContext":
        configured = (
            os.environ.get("WL_HOME")
            or os.environ.get("WONDERLAND_ROOT")
        )

        if configured:
            candidate = Path(configured).expanduser().resolve()

            if (candidate / ".git").exists():
                return cls(root=candidate)

        candidate = Path(__file__).resolve().parents[4]

        if (candidate / ".git").exists():
            return cls(root=candidate)

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
                return cls(root=candidate)

        raise PlatformContextError(
            "unable to locate Wonderland repository root"
        )

    def environment(self) -> dict[str, str]:
        env = os.environ.copy()
        env["WL_HOME"] = str(self.root)
        env["WONDERLAND_ROOT"] = str(self.root)
        env["WL_PLATFORM_ENGINE"] = "1"
        env["WL_PLATFORM_AGGREGATED"] = "1"
        env["WL_NONINTERACTIVE"] = "1"
        env["CI"] = env.get("CI", "1")
        return env
