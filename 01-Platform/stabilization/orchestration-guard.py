#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]

RULES = {
    "01-Platform/certification/platform-certify.py": [
        "wl-platform-status",
        "wl-platform-finalize",
    ],
    "01-Platform/certification/platform-finalize.py": [
        "wl-platform-status",
        "wl-platform-certify",
    ],
    "01-Platform/status/platform-status.py": [
        "wl-platform-finalize",
        "wl-platform-certify",
    ],
}


def main() -> int:
    failures = 0

    print("Wonderland Platform Orchestration Guard")
    print()

    for rel, forbidden in RULES.items():
        path = ROOT / rel

        if not path.exists():
            print(f"WARN missing checked file: {rel}")
            continue

        text = path.read_text(errors="ignore")

        for token in forbidden:
            if token in text:
                print(f"FAIL {rel} contains forbidden orchestration call: {token}")
                failures += 1

    if failures:
        print()
        print(f"FAIL orchestration guard: {failures} issue(s)")
        print("RESULT FAIL")
        return 1

    print("PASS no forbidden recursive orchestration calls")
    print("RESULT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
