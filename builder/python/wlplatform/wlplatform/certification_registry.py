from __future__ import annotations

import hashlib
from pathlib import Path


class CertificationRegistry:

    VERSION = 1

    def __init__(self, root: Path):

        self.root = root.resolve()

        base = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
        )

        self.engine_dir = base / "engines"
        self.active_dir = base / "normalized"

    def digest(self, path: Path):

        if not path.exists():
            return None

        return (
            "sha256:"
            + hashlib.sha256(
                path.read_bytes()
            ).hexdigest()
        )

    def normalize_engine_name(
        self,
        filename: str,
    ):

        name = filename.lower()

        mappings = {
            "runtime": "runtime",
            "academy": "academy",
            "security": "security",
            "architecture": "architecture",
            "builder": "builder",
            "repository": "repository",
            "doctor": "doctor",
            "certificate": "certificate",
            "platform": "platform",
            "governance": "governance",
            "mirror": "mirror",
            "registry": "registry",
        }

        for key, value in mappings.items():

            if key in name:
                return value

        return (
            name
            .replace(".json", "")
        )

    def discover(self):

        results = {}

        if not self.active_dir.exists():
            return results

        for path in sorted(
            self.active_dir.glob("*.json")
        ):

            engine = self.normalize_engine_name(
                path.name
            )

            import json

            try:
                data = json.loads(
                    path.read_text()
                )
            except Exception:
                data = {}

            results[engine] = self.normalize_status(
                {
                    "engine": engine,
                    "artifact": str(
                        path.relative_to(
                            self.root
                        )
                    ),
                    "status": data.get(
                        "status"
                    ),
                    "certified": data.get(
                        "certified",
                        False,
                    ),
                    "digest": self.digest(path),
                }
            )

        return results

    def normalize_active(self):

        active = self.discover()

        return {
            name: self.normalize_status(
                dict(entry)
            )
            for name, entry in active.items()
        }

    def active(self):

        return self.normalize_active()

    def load(self):

        return {
            "schema_version": self.VERSION,
            "active": self.active(),
            "platform": {},
            "trust": {},
            "graph": {},
        }


    def normalize_status(self, entry: dict) -> dict:
        """
        Normalize certification artifact state.
        """

        status = entry.get("status")
        certified = entry.get(
            "certified",
            False,
        )

        if certified and not status:
            status = "PASS"

        if status == "PASS":
            certified = True

        entry["status"] = status or "UNKNOWN"
        entry["certified"] = certified

        return entry

