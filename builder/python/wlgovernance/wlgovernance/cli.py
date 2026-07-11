"""CLI for Wonderland Governance Engine."""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Any

from .engine import GovernanceEngine


def discover_root() -> Path:
    configured = os.environ.get("WL_ROOT")

    if configured:
        root = Path(configured).expanduser().resolve()

        if (root / ".git").exists():
            return root

    candidate = Path(
        "/Users/wonderland/Wonderland"
    )

    if candidate.exists():
        return candidate.resolve()

    current = Path.cwd().resolve()

    for path in (current, *current.parents):
        if (path / ".git").exists():
            return path

    raise RuntimeError(
        "unable to locate Wonderland repository"
    )


def parser() -> argparse.ArgumentParser:
    value = argparse.ArgumentParser(
        prog="wl-governance",
        description=(
            "Wonderland Governance authority and "
            "certification engine"
        ),
    )

    subcommands = value.add_subparsers(
        dest="command",
        required=True,
    )

    subcommands.add_parser(
        "verify",
        help="run structural governance verification",
    )
    subcommands.add_parser(
        "audit",
        help="run governance and repository audit",
    )
    subcommands.add_parser(
        "doctor",
        help="run consolidated governance diagnostics",
    )
    subcommands.add_parser(
        "report",
        help="generate consolidated governance report",
    )
    subcommands.add_parser(
        "state",
        help="show persistent governance state",
    )
    subcommands.add_parser(
        "version",
        help="show Governance Engine version",
    )

    certify = subcommands.add_parser(
        "certify",
        help="generate governance certification",
    )
    certify.add_argument(
        "--require-clean",
        action="store_true",
        help="require a clean Git worktree",
    )

    subcommands.add_parser(
        "release-gate",
        help="run strict governance release gate",
    )

    return value


def emit(value: dict[str, Any]) -> int:
    print(
        json.dumps(
            value,
            indent=2,
            sort_keys=True,
        )
    )

    return (
        0
        if value.get("result") == "PASS"
        else 1
    )


def main(argv: list[str] | None = None) -> int:
    arguments = parser().parse_args(argv)

    try:
        engine = GovernanceEngine(
            discover_root()
        )

        if arguments.command == "verify":
            result = engine.verify()
        elif arguments.command == "audit":
            result = engine.audit()
        elif arguments.command == "doctor":
            result = engine.doctor()
        elif arguments.command == "report":
            result = engine.report()
        elif arguments.command == "state":
            result = engine.state()
        elif arguments.command == "certify":
            result = engine.certify(
                require_clean=arguments.require_clean
            )
        elif arguments.command == "release-gate":
            result = engine.release_gate()
        elif arguments.command == "version":
            result = engine.version()
        else:
            raise RuntimeError(
                f"unsupported command: {arguments.command}"
            )

        return emit(result)

    except Exception as exc:
        return emit(
            {
                "result": "FAIL",
                "error": (
                    f"{type(exc).__name__}: {exc}"
                ),
            }
        )


if __name__ == "__main__":
    raise SystemExit(main())
