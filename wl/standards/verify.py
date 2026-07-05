from __future__ import annotations

import json
from pathlib import Path


REQUIRED = [
    "docs/architecture/wonderland-architecture-standard-v1.md",
    "wl/standards/architecture_standard.json",
    "wl/operator/subsystem.json",
    "wl/operator/kernel.py",
    "wl/operator/status.py",
    "wl/operator/events.py",
    "wl/operator/notifications.py",
    "wl/operator/verify.py",
]


def check_file(path: str) -> bool:
    p = Path(path)
    if p.exists():
        print(f"PASS file {path}")
        return True
    print(f"FAIL file {path}")
    return False


def main() -> int:
    ok = True

    for item in REQUIRED:
        ok = check_file(item) and ok

    standard = Path("wl/standards/architecture_standard.json")
    if standard.exists():
        try:
            data = json.loads(standard.read_text())
            if data.get("version") == "1.0":
                print("PASS standard version 1.0")
            else:
                print("FAIL standard version")
                ok = False
            if data.get("reference_implementation") == "wl/operator":
                print("PASS reference implementation wl/operator")
            else:
                print("FAIL reference implementation")
                ok = False
        except Exception as exc:
            print(f"FAIL standard invalid: {exc}")
            ok = False

    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
