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
        self.active_dir = base / "active"


    def digest(self, path: Path):

        if not path.exists():
            return None

        return (
            "sha256:"
            + hashlib.sha256(
                path.read_bytes()
            ).hexdigest()
        )


    def normalize_engine_name(self, filename: str):

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
        }

        for key, value in mappings.items():

            if key in name:
                return value

        return (
            name
            .replace(
                "-certification.json",
                ""
            )
            .replace(
                ".json",
                ""
            )
        )


    def discover(self):

        results = {}

        if not self.active_dir.exists():
            return results

        for path in sorted(
            self.active_dir.glob("*.json")
        ):

            name = self.normalize_engine_name(
                path.name
            )

            results[name] = {
                "_engine": name,
                "artifact": str(
                    path.relative_to(
                        self.root
                    )
                ),
                "certified": True,
                "digest": self.digest(path),
                "generated": None,
                "dependencies": [],

            }

        return results


    def normalize_active(self):

        discovered = self.discover()

        priority = {}

        for item in discovered.values():

            engine = item.pop(
                "_engine",
                None
            )

            if engine is None:
                engine = self.normalize_engine_name(
                    item.get("path", "")
                )

            priority.setdefault(
                engine,
                []
            ).append(item)


        normalized = {}

        for engine, items in priority.items():

            chosen = sorted(
                items,
                key=lambda x: x["artifact"]
            )[0]

            normalized[engine] = chosen

        return dict(
            sorted(
                normalized.items()
            )
        )


    def active(self):

        return self.normalize_active()


    def load(self):

        active = self.active()

        return {
            "schema_version": self.VERSION,
            "active": active,
            "platform": {},
            "trust": {},
            "graph": {},
        }
