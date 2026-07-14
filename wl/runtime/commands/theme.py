#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json

from wl.runtime.themes import THEMES


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="wl runtime theme",
        description="List Wonderland runtime UI themes.",
    )
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    if args.json:
        print(json.dumps(THEMES, indent=2))
        return 0

    print("Wonderland Runtime Themes")
    print()
    for name, theme in THEMES.items():
        print(f"- {name}: {theme['subtitle']}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
