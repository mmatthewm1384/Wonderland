from __future__ import annotations

import argparse

from wl.runtime.launcher import launch_rootless


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Start Wonderland Runtime.")
    parser.add_argument("--ticks", type=int, default=60)
    parser.add_argument("--theme", default="default")
    parser.add_argument("--state-dir", default=None)
    parser.add_argument("--non-interactive", action="store_true")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    return launch_rootless(
        ticks=args.ticks,
        interactive=not args.non_interactive,
        state_dir=args.state_dir,
        theme=args.theme,
    )


__all__ = ["build_parser", "main", "launch_rootless"]


if __name__ == "__main__":
    raise SystemExit(main())
