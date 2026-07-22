from __future__ import annotations

import hashlib
import json
import shutil

from datetime import datetime, timezone
from pathlib import Path


class CertificationMigration:


    VERSION = 1


    def __init__(
        self,
        root: Path,
    ):
        self.root = root.resolve()

        self.base = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
        )

        self.engine_dir = (
            self.base
            / "engines"
        )

        self.report_dir = (
            self.base
            / "reports"
        )


    def digest(
        self,
        path: Path,
    ) -> str:

        return hashlib.sha256(
            path.read_bytes()
        ).hexdigest()


    def classify(
        self,
        path: Path,
    ):

        name = path.name.lower()

        if (
            "backup" in name
            or ".bak" in name
        ):
            return "backup"

        if path.parent.name == "engines":
            return "engine"

        if path.parent.name == "reports":
            return "report"

        if path.parent.name == "graph":
            return "graph"

        return "legacy"


    def discover(self):

        results = []

        for path in self.base.rglob(
            "*.json"
        ):

            results.append(
                {
                    "path": path,
                    "class": self.classify(path),
                }
            )

        return results


    def engine_name(
        self,
        path: Path,
    ):

        name = path.stem

        name = name.replace(
            "-certification",
            "",
        )

        return name


    def migrate(
        self,
        dry_run=True,
    ):

        self.engine_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

        migrated = []
        skipped = []


        for item in self.discover():

            path = item["path"]
            category = item["class"]


            if category != "legacy":
                continue


            try:

                payload = json.loads(
                    path.read_text(
                        encoding="utf-8"
                    )
                )

            except Exception:

                skipped.append(
                    {
                        "artifact": str(path),
                        "reason":
                            "invalid-json",
                    }
                )

                continue


            if not (
                "certified" in payload
                or "certification" in payload
            ):
                skipped.append(
                    {
                        "artifact": str(path),
                        "reason":
                            "not-certification",
                    }
                )

                continue


            engine = self.engine_name(
                path
            )

            destination = (
                self.engine_dir
                /
                f"{engine}-certification.json"
            )


            record = {
                "engine": engine,
                "source": str(path),
                "destination": str(destination),
                "digest": self.digest(path),
            }


            if destination.exists():

                skipped.append(
                    {
                        **record,
                        "reason":
                            "destination-exists",
                    }
                )

                continue


            if not dry_run:

                shutil.copy2(
                    path,
                    destination,
                )


            migrated.append(
                record
            )


        report = {
            "schema_version":
                self.VERSION,

            "migration":
                "Certification Engine 1.3B",

            "generated":
                datetime.now(
                    timezone.utc
                ).isoformat(),

            "dry_run":
                dry_run,

            "migrated":
                migrated,

            "skipped":
                skipped,
        }


        if not dry_run:

            output = (
                self.report_dir
                /
                "certification-migration.json"
            )

            output.write_text(
                json.dumps(
                    report,
                    indent=2,
                    sort_keys=True,
                )
                + "\n",
                encoding="utf-8",
            )


        return report
