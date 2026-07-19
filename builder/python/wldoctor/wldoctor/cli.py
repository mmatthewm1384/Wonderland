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


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="wl doctor",
        description="Wonderland Doctor Engine",
    )

    sub = parser.add_subparsers(
        dest="command"
    )

    base = sub.add_parser(
        "status"
    )
    base.add_argument(
        "--json",
        action="store_true",
    )

    graph = sub.add_parser(
        "graph"
    )
    graph.add_argument(
        "--json",
        action="store_true",
    )

    certify = sub.add_parser(
        "certify"
    )
    certify.add_argument(
        "--json",
        action="store_true",
    )

    verify = sub.add_parser(
        "verify-certificate"
    )
    verify.add_argument(
        "--json",
        action="store_true",
    )

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    root = repository_root()
    engine = DoctorEngine(root)

    command = args.command or "status"

    if command == "status":
        payload = engine.doctor()

    elif command == "graph":
        payload = engine.certification_graph()

    elif command == "certify":
        payload = engine.write_certificate()

    elif command == "verify-certificate":
        payload = engine.verify_certificate()

    else:
        parser.error(
            f"unknown command: {command}"
        )

    if getattr(args, "json", False):
        print(
            json.dumps(
                payload,
                indent=2,
                sort_keys=True,
            )
        )
    else:
        print(
            "Wonderland Doctor"
        )

        for key, value in payload.items():
            if isinstance(value, (str, int, bool)):
                print(
                    f"{key}={value}"
                )

    if payload.get("certified") is False:
        return 1

    if payload.get("result") == "FAIL":
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
