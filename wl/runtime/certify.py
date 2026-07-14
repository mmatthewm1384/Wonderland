from __future__ import annotations

import argparse
import json
import time
from dataclasses import asdict
from datetime import datetime, timezone
from pathlib import Path

from wl.runtime.manager import CommandResult, RuntimeManager


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def write_report(results: list[CommandResult]) -> Path:
    root = repo_root()
    report = {
        "schema": "wonderland.runtime.certify.v1",
        "ok": all(result.ok for result in results),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "steps": [asdict(result) for result in results],
    }

    preferred = root / "state" / "runtime" / "certify.json"
    preferred.parent.mkdir(parents=True, exist_ok=True)

    try:
        preferred.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        return preferred
    except OSError:
        fallback = Path("/tmp") / "wonderland-runtime-certify.json"
        fallback.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        return fallback


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="wl runtime certify",
        description="Certify the Wonderland runtime lifecycle.",
    )
    parser.add_argument("--debug", action="store_true", help="Print detailed lifecycle output.")
    parser.add_argument("--leave-running", action="store_true", help="Leave runtime running at the end.")
    parser.add_argument("--delay", type=float, default=1.0, help="Delay between lifecycle transitions.")
    return parser


def run_step(
    name: str,
    results: list[CommandResult],
    action,
    debug: bool,
    delay: float,
) -> bool:
    print(f"== {name} ==")
    result: CommandResult = action()
    results.append(result)

    if not result.ok:
        path = write_report(results)
        print(f"FAIL runtime certification: {name}")
        print(f"Report: {path}")
        return False

    if delay > 0:
        time.sleep(delay)

    return True


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)

    manager = RuntimeManager()
    results: list[CommandResult] = []

    steps = [
        ("start", lambda: manager.start(debug=args.debug)),
        ("verify-after-start", lambda: manager.verify(debug=args.debug)),
        ("report-after-start", lambda: manager.report(debug=args.debug)),
        ("restart", lambda: manager.restart(debug=args.debug)),
        ("verify-after-restart", lambda: manager.verify(debug=args.debug)),
    ]

    if not args.leave_running:
        steps.extend(
            [
                ("stop", lambda: manager.stop(debug=args.debug)),
                ("report-after-stop", lambda: manager.report(debug=args.debug)),
            ]
        )

    for name, action in steps:
        if not run_step(name, results, action, args.debug, args.delay):
            return 1

    path = write_report(results)
    print("PASS runtime certification")
    print(f"Report: {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
