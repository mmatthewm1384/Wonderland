from __future__ import annotations

import json
from pathlib import Path


REQUIRED = [
    "wl/operator/__main__.py",
    "wl/operator/core.py",
    "wl/operator/registry.py",
    "wl/operator/dashboard.py",
    "wl/operator/subsystem.json",
    "docs/operator/README.md",
]


def main() -> int:
    ok = True

    for item in REQUIRED:
        path = Path(item)
        if path.exists():
            print(f"PASS file {item}")
        else:
            print(f"FAIL file {item}")
            ok = False

    manifest = Path("wl/operator/subsystem.json")
    if manifest.exists():
        try:
            data = json.loads(manifest.read_text())
            if data.get("name") == "operator":
                print("PASS manifest name operator")
            else:
                print("FAIL manifest name")
                ok = False
        except Exception as exc:
            print(f"FAIL manifest invalid: {exc}")
            ok = False

    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
