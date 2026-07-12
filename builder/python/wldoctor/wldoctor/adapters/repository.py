from __future__ import annotations

from pathlib import Path
from typing import Any


class RepositoryAdapter:
    name = "repository"

    def run(self, root: Path) -> dict[str, Any]:
        from wlrepository.engine import RepositoryEngine

        return RepositoryEngine(root).doctor()
