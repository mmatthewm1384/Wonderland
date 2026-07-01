from __future__ import annotations

import argparse


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="python3 -m wlbuilder",
        description="Wonderland OS image builder",
    )
    parser.add_argument("--profile", default="development")
    parser.add_argument("--version", default="0.1.2-dev")
    args = parser.parse_args()

    print("Wonderland Image Builder")
    print(f"Profile: {args.profile}")
    print(f"Version: {args.version}")
    print("PASS framework entrypoint")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
