from __future__ import annotations

import argparse
from pathlib import Path

from wl.runtime.shutdown import ShutdownManager


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="wl stop",
        description="Stop the Wonderland runtime cleanly.",
    )
    parser.add_argument("--force", action="store_true", help="Escalate to SIGKILL when graceful shutdown does not complete.")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be stopped or cleaned without changing anything.")
    parser.add_argument("--keep-state", action="store_true", help="Preserve transient runtime state files.")
    parser.add_argument("--debug", action="store_true", help="Print detailed shutdown output.")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)

    manager = ShutdownManager(
        root=Path.cwd(),
        dry_run=args.dry_run,
        force=args.force,
        keep_state=args.keep_state,
    )
    result = manager.shutdown()

    print(result.message)

    if args.debug or args.dry_run:
        for item in result.stopped:
            print(f"STOP {item}")
        for item in result.skipped:
            print(f"SKIP {item}")
        for item in result.errors:
            print(f"FAIL {item}")

    return 0 if result.ok else 1

if __name__ == "__main__":
    raise SystemExit(main())
