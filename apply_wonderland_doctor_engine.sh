#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BASE="builder/python/wldoctor"

echo "Creating Wonderland Doctor Engine..."

mkdir -p \
 "$BASE/wldoctor" \
 "$BASE/tests"

cat > "$BASE/wldoctor/__init__.py" <<'PY'
from .engine import DoctorEngine

__all__ = [
    "DoctorEngine",
]
PY

cat > "$BASE/wldoctor/engine.py" <<'PY'
from __future__ import annotations

from pathlib import Path
from typing import Any


class DoctorEngine:
    def __init__(self, root: Path) -> None:
        self.root = root.resolve()

    def repository_check(self) -> dict[str, Any]:
        from wlrepository.engine import RepositoryEngine

        engine = RepositoryEngine(self.root)

        return engine.doctor()

    def doctor(self) -> dict[str, Any]:
        systems: dict[str, Any] = {}

        try:
            systems["repository"] = self.repository_check()
        except Exception as exc:
            systems["repository"] = {
                "schema_version": 1,
                "engine": "repository",
                "status": "FAIL",
                "error": str(exc),
            }

        status = (
            "PASS"
            if all(
                item.get("status") == "PASS"
                for item in systems.values()
            )
            else "FAIL"
        )

        return {
            "schema_version": 1,
            "engine": "wonderland-doctor",
            "status": status,
            "systems": systems,
        }
PY

cat > "$BASE/wldoctor/cli.py" <<'PY'
from __future__ import annotations

import argparse
import json
import os
import subprocess
from pathlib import Path

from .engine import DoctorEngine


def repository_root() -> Path:
    configured = os.environ.get("WL_ROOT")

    if configured:
        return Path(configured).resolve()

    result = subprocess.run(
        [
            "git",
            "rev-parse",
            "--show-toplevel",
        ],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )

    return Path(result.stdout.strip()).resolve()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="wl doctor",
    )

    parser.add_argument(
        "--json",
        action="store_true",
    )

    args = parser.parse_args(argv)

    report = DoctorEngine(
        repository_root()
    ).doctor()

    if args.json:
        print(
            json.dumps(
                report,
                indent=2,
                sort_keys=True,
            )
        )
    else:
        print(
            "Wonderland Doctor"
        )
        print(
            f"status={report['status']}"
        )

        for name, system in report["systems"].items():
            print(
                f"{name}={system['status']}"
            )

    return (
        0
        if report["status"] == "PASS"
        else 1
    )


if __name__ == "__main__":
    raise SystemExit(main())
PY

cat > "$BASE/tests/test_doctor_engine.py" <<'PY'
from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from wldoctor.engine import DoctorEngine


class DoctorEngineTests(unittest.TestCase):

    def test_schema_contract(self):
        with tempfile.TemporaryDirectory() as tmp:
            report = DoctorEngine(
                Path(tmp)
            ).doctor()

            self.assertEqual(
                report["schema_version"],
                1,
            )

            self.assertEqual(
                report["engine"],
                "wonderland-doctor",
            )

            self.assertIn(
                report["status"],
                ("PASS", "FAIL"),
            )


if __name__ == "__main__":
    unittest.main()
PY

echo
echo "Testing Doctor Engine..."

PYTHONPATH=builder/python/wldoctor:builder/python/wlrepository \
python -m pytest builder/python/wldoctor/tests

echo
echo "Doctor report..."

PYTHONPATH=builder/python/wldoctor:builder/python/wlrepository \
python -m wldoctor.cli --json

echo
echo "Wonderland Doctor Engine installed."
