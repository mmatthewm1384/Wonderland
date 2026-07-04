from __future__ import annotations

import argparse
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import TextIO


@dataclass(slots=True)
class RuntimeContext:
    repo_root: Path
    args: argparse.Namespace
    env: dict[str, str] = field(default_factory=lambda: dict(os.environ))
    stdout: TextIO = sys.stdout
    stderr: TextIO = sys.stderr

    @property
    def profile(self) -> str:
        return getattr(self.args, "profile", "development")

    @property
    def as_json(self) -> bool:
        return getattr(self.args, "json", False)

    @property
    def hygiene_action(self) -> str:
        return getattr(self.args, "action", "check")
