#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def main():
    try:
        subprocess.run(["nerdctl", "compose", "-f", str(ROOT / "compose.yml"), "down", "--remove-orphans"], check=True)
        subprocess.run(["nerdctl", "compose", "-f", str(ROOT / "compose.yml"), "up", "-d"], check=True)
        sys.exit(0)
    except Exception as exc:
        print(f"FAIL repair failed: {exc}")
        sys.exit(1)

if __name__ == "__main__":
    main()
