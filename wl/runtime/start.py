from __future__ import annotations

import argparse
from pathlib import Path

from wl.runtime.context import RuntimeContext
from wl.runtime.launcher import run_scene
from wl.runtime.scenes.boot import BootScene


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Start the Wonderland Runtime boot scene.")
    parser.add_argument("--ticks", type=int, default=60)
    parser.add_argument("--theme", default="default")
    parser.add_argument("--state-dir", default=None)
    parser.add_argument("--no-alt-screen", action="store_true")
    parser.add_argument("--non-interactive", action="store_true")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    context = RuntimeContext(
        interactive=not args.non_interactive,
        state_dir=Path(args.state_dir) if args.state_dir else None,
        theme=args.theme,
    )
    return run_scene(
        BootScene(max_ticks=args.ticks),
        context=context,
        alternate_screen=not args.no_alt_screen,
    )


if __name__ == "__main__":
    raise SystemExit(main())
