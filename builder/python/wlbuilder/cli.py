from __future__ import annotations

import argparse


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="python3 -m wlbuilder",
        description="Wonderland OS Builder Runtime",
    )

    parser.add_argument(
        "--profile",
        default="development",
        help="Builder profile to use",
    )

    args = parser.parse_args(argv)

    # Temporary placeholder until the old image logic is moved into runtime stages.
    print(f"wlbuilder runtime active: profile={args.profile}")
    return 0
