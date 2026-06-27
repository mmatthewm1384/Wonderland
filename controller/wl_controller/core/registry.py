from __future__ import annotations

import json
from pathlib import Path


class Registry:
    def __init__(self, root: Path):
        self.root = root
        self.registry_dir = root / "vault/05-Registry"
        self.services_file = self.registry_dir / "services.json"
        self.desired_file = self.registry_dir / "desired-state.json"

    def _read_json(self, path: Path) -> dict:
        if not path.exists():
            return {"valid": False, "path": str(path), "error": "missing"}

        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except Exception as e:
            return {"valid": False, "path": str(path), "error": str(e)}

    def services(self) -> dict:
        return self._read_json(self.services_file)

    def desired_state(self) -> dict:
        return self._read_json(self.desired_file)

    def valid(self) -> bool:
        return self.services_file.exists() and self.desired_file.exists()
