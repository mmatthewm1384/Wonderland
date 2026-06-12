#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPOSE = ROOT / "compose.yml"

def main():
    subprocess.run(["nerdctl", "compose", "-f", str(COMPOSE), "down", "--remove-orphans"], check=False)
    subprocess.run(["nerdctl", "compose", "-f", str(COMPOSE), "up", "-d", "--build"], check=True)
    print("RESULT PASS")

if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"FAIL repair failed: {exc}")
        sys.exit(1)
