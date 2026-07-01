from __future__ import annotations

import argparse
import platform
import runpy
import sys
from pathlib import Path


def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


def main() -> int:
    if platform.system() == "Darwin":
        print("FAIL: direct wlbuilder execution on macOS is unsupported.", file=sys.stderr)
        print("Use: bin/wl builder build --profile development", file=sys.stderr)
        return 1

    root = repo_root()
    builder = root / "images" / "build-qcow2.py"

    parser = argparse.ArgumentParser(
        prog="python3 -m wlbuilder",
        description="Wonderland OS Python image builder",
    )
    parser.add_argument("--profile", default="development")
    parser.add_argument("--output-dir", default=None)
    parser.add_argument("--no-qcow2", action="store_true")

    args, passthrough = parser.parse_known_args()

    if not builder.exists():
        print(f"FAIL: builder wrapper not found: {builder}", file=sys.stderr)
        return 1

    argv = [str(builder), "--profile", args.profile]

    if args.output_dir:
        argv += ["--output-dir", args.output_dir]

    if args.no_qcow2:
        argv += ["--no-qcow2"]

    argv += passthrough

    sys.argv = argv
    runpy.run_path(str(builder), run_name="__main__")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
