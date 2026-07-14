from __future__ import annotations

import argparse
import sys

from wl.runtime.manager import RuntimeManager


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="wl restart",
        description="Restart the Wonderland runtime using the governed lifecycle.",
    )
    parser.add_argument("--debug", action="store_true", help="Print detailed lifecycle output.")
    parser.add_argument("--force", action="store_true", help="Force stop if graceful shutdown does not complete.")
    parser.add_argument("--verify", action="store_true", help="Run runtime verify after restart.")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)

    manager = RuntimeManager()
    result = manager.restart(debug=args.debug, force=args.force)

    if not result.ok:
        print("FAIL Wonderland runtime restart", file=sys.stderr)
        return result.returncode or 1

    if args.verify:
        verify = manager.verify(debug=True)
        if not verify.ok:
            print("FAIL runtime verify after restart", file=sys.stderr)
            return verify.returncode or 1

    print("PASS Wonderland runtime restarted")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
