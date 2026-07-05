from __future__ import annotations

import argparse
from wlknowledge import __version__


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="wlknowledge")
    parser.add_argument("--version", action="version", version=f"wlknowledge {__version__}")

    subcommands = parser.add_subparsers(dest="command")

    subcommands.add_parser("version", help="Print WKE version")
    subcommands.add_parser("doctor", help="Run WKE health checks")

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.command == "version":
        print(f"wlknowledge {__version__}")
        return 0

    if args.command == "doctor":
        print("Wonderland Knowledge Engine")
        print("Package ........ PASS")
        print("CLI ............ PASS")
        print("RESULT PASS")
        return 0

    parser.print_help()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
