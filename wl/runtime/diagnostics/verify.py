#!/usr/bin/env python3
from __future__ import annotations

import argparse
import importlib
import json
import os
import sys
import time
from pathlib import Path


def root() -> Path:
    return Path(os.environ.get("WONDERLAND_ROOT") or os.environ.get("WL_HOME") or Path.cwd()).resolve()


def report_path() -> Path:
    return root() / "state/runtime/verify.json"


def check(condition: bool, message: str) -> dict[str, object]:
    status = "pass" if condition else "fail"
    return {"name": message, "status": status}


def write_report(checks: list[dict[str, object]]) -> Path:
    path = report_path()
    path.parent.mkdir(parents=True, exist_ok=True)

    payload = {
        "schema": "wonderland.runtime.verify.v1",
        "status": "pass" if all(c["status"] == "pass" for c in checks) else "fail",
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "checks": checks,
    }

    tmp = path.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(payload, indent=2) + "\n")
    tmp.replace(path)
    return path


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="wl runtime verify",
        description="Verify Wonderland runtime framework integrity.",
    )
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    r = root()
    checks: list[dict[str, object]] = [
        check((r / "wl/runtime/startup.py").exists(), "runtime startup renderer exists"),
        check((r / "wl/runtime/checks.py").exists(), "runtime checks module exists"),
        check((r / "lib/wonderland/runtime/start.sh").exists(), "runtime shell launcher exists"),
        check((r / "bin/wl-start").exists(), "wl-start wrapper exists"),
        check((r / "bin/wl").exists(), "wl command exists"),
        check((r / "design/runtime").exists(), "runtime design library exists"),
    ]

    try:
        importlib.import_module("wl.runtime.startup")
        importlib.import_module("wl.runtime.checks")
        themes = importlib.import_module("wl.runtime.themes")
        checks.extend([
            check(True, "wl.runtime.startup imports"),
            check(bool(themes.THEMES), "runtime themes registered"),
            check("neon" in themes.THEMES, "neon theme exists"),
            check("minimal" in themes.THEMES, "minimal theme exists"),
            check("matrix" in themes.THEMES, "matrix theme exists"),
        ])
    except Exception as exc:
        checks.append({"name": f"runtime imports failed: {exc}", "status": "fail"})

    path = write_report(checks)
    ok = all(c["status"] == "pass" for c in checks)

    if args.json:
        print(path.read_text(), end="")
        return 0 if ok else 1

    for item in checks:
        label = item["status"].upper()
        stream = sys.stderr if item["status"] == "fail" else sys.stdout
        print(f"{label}: {item['name']}", file=stream)

    print(f"REPORT: {path}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
