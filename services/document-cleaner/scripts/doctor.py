#!/usr/bin/env python3
import subprocess
import sys
import urllib.request

def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True)

def main():
    running = run(["nerdctl", "inspect", "-f", "{{.State.Running}}", "wl-document-cleaner"]).stdout.strip()
    if running != "true":
        print("FAIL wl-document-cleaner not running")
        sys.exit(1)

    try:
        with urllib.request.urlopen("http://127.0.0.1:8788/healthz", timeout=5) as r:
            body = r.read().decode()
            if "wl-document-cleaner" not in body:
                print("FAIL healthz invalid")
                sys.exit(1)
    except Exception as exc:
        print(f"FAIL healthz failed: {exc}")
        sys.exit(1)

    dep = run(["nerdctl", "exec", "wl-document-cleaner", "exiftool", "-ver"])
    if dep.returncode != 0:
        print("FAIL exiftool missing")
        sys.exit(1)

    print("RESULT PASS")

if __name__ == "__main__":
    main()
