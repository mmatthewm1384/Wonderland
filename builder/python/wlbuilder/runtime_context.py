from __future__ import annotations

import argparse
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import TextIO

from wlbuilder.context import BuilderContext, create_context


@dataclass(slots=True)
class RuntimeContext:
    repo_root: Path
    args: argparse.Namespace
    env: dict[str, str] = field(default_factory=lambda: dict(os.environ))
    stdout: TextIO = sys.stdout
    stderr: TextIO = sys.stderr
    _builder: BuilderContext | None = field(default=None, init=False, repr=False)

    @property
    def builder(self) -> BuilderContext:
        if self._builder is None:
            self._builder = create_context(self.repo_root, self.profile)
        return self._builder

    @property
    def profile(self) -> str:
        return getattr(self.args, "profile", "development")

    @property
    def as_json(self) -> bool:
        return getattr(self.args, "json", False)

    @property
    def hygiene_action(self) -> str:
        return getattr(self.args, "action", "check")
