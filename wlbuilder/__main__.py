from __future__ import annotations

import argparse
import platform
import runpy
import sys
from pathlib import Path


def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


def build_entrypoint(root: Path) -> Path:
    return root / "images" / "build-qcow2.py"


def main(argv: list[str] | None = None) -> int:
    if platform.system() == "Darwin":
        print("FAIL: direct wlbuilder execution on macOS is unsupported.", file=sys.stderr)
        print("Use: bin/wl builder build --profile development", file=sys.stderr)
        return 1

    parser = argparse.ArgumentParser(
        prog="python3 -m wlbuilder",
        description="Wonderland OS image builder entry point",
    )
    parser.add_argument("--profile", default="development")
    parser.add_argument("--output-dir")
    parser.add_argument("--no-qcow2", action="store_true")

    args, passthrough = parser.parse_known_args(argv)

    root = repo_root()
    entrypoint = build_entrypoint(root)

    if not entrypoint.is_file():
        print(f"FAIL: builder entrypoint not found: {entrypoint}", file=sys.stderr)
        return 1

    forwarded = [str(entrypoint), "--profile", args.profile]

    if args.output_dir:
        forwarded += ["--output-dir", args.output_dir]

    if args.no_qcow2:
        forwarded.append("--no-qcow2")

    forwarded += passthrough

    sys.argv = forwarded
    runpy.run_path(str(entrypoint), run_name="__main__")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
