#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
from pathlib import Path


ROOT = Path.home() / "Wonderland"


def main() -> int:
    manifest = ROOT / "runtime/release/manifest-latest.json"
    cert = ROOT / "runtime/release/certification-latest.json"
    pkg = ROOT / "runtime/release/wonderland-platform-latest.tar.gz"

    failures = []

    for path in [manifest, cert, pkg]:
        if not path.exists():
            failures.append(f"missing: {path}")

    if cert.exists():
        data = json.loads(cert.read_text())
        if data.get("status") != "PASS":
            failures.append("certification status is not PASS")

    if pkg.exists():
        p = subprocess.run(["tar", "-tzf", str(pkg)], text=True, capture_output=True, check=False)
        if p.returncode != 0:
            failures.append("package is not readable")

    if failures:
        print("RESULT FAIL")
        for failure in failures:
            print(f"FAIL {failure}")
        return 1

    print("RESULT PASS")
    print(f"PASS manifest {manifest}")
    print(f"PASS certification {cert}")
    print(f"PASS package {pkg}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
