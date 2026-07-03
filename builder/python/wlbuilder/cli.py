from __future__ import annotations

import argparse
from collections.abc import Sequence


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="python3 -m wlbuilder",
        description="Wonderland OS Builder Runtime",
    )

    subcommands = parser.add_subparsers(dest="command")

    status = subcommands.add_parser("status", help="Show builder runtime status")
    status.set_defaults(command="status")

    doctor = subcommands.add_parser("doctor", help="Run builder runtime diagnostics")
    doctor.set_defaults(command="doctor")

    verify = subcommands.add_parser("verify", help="Verify builder runtime contract")
    verify.set_defaults(command="verify")

    artifacts = subcommands.add_parser("artifacts", help="List Builder v2 artifacts")
    artifacts.set_defaults(command="artifacts")

    stages = subcommands.add_parser("stages", help="List Builder v2 stages")
    stages.add_argument("--json", action="store_true", help="Emit stage metadata as JSON")
    stages.set_defaults(command="stages")

    docs = subcommands.add_parser("docs", help="Generate Builder v2 documentation")
    docs.set_defaults(command="docs")

    native_state = subcommands.add_parser("native-state", help="Show native Builder v2 stage state")
    native_state.add_argument("--json", action="store_true", help="Emit native stage state as JSON")
    native_state.set_defaults(command="native-state")


    build = subcommands.add_parser("build", help="Build a Wonderland OS image")
    build.add_argument(
        "--profile",
        default="development",
        help="Builder profile to use",
    )
    build.set_defaults(command="build")

    return parser


def parse(argv: Sequence[str] | None = None) -> argparse.Namespace:
    return build_parser().parse_args(list(argv) if argv is not None else None)
