from __future__ import annotations

import os
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
            os.environ.get("WL_ROOT")
            or os.environ.get("WL_HOME")
            or os.environ.get("WONDERLAND_ROOT")
        )

        if configured:
            candidate = Path(configured).expanduser().resolve()

            if (candidate / ".git").exists():
                return cls(root=candidate)

        candidate = Path(__file__).resolve().parents[5]

        if (candidate / ".git").exists():
            return cls(root=candidate)

        # Repository identity must never depend on PWD.
        raise PlatformContextError(
            "unable to locate Wonderland repository root"
        )

    def environment(self) -> dict[str, str]:
        env = os.environ.copy()

        # Canonical root authority.
        env["WL_ROOT"] = str(self.root)

        # Compatibility aliases. These are outputs of the canonical
        # root resolution, never independent root authorities.
        env["WL_HOME"] = str(self.root)
        env["WONDERLAND_ROOT"] = str(self.root)

        env["WL_PLATFORM_ENGINE"] = "1"
        env["WL_PLATFORM_AGGREGATED"] = "1"
        env["WL_NONINTERACTIVE"] = "1"
        env["CI"] = env.get("CI", "1")

        return env
