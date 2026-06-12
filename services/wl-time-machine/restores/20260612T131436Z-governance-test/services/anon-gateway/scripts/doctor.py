#!/usr/bin/env python3
import json
import subprocess
import sys

def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True)

def main():
    tor = run(["nerdctl", "inspect", "-f", "{{.State.Running}}", "wl-anon-tor"])
    if tor.stdout.strip() != "true":
        print("FAIL wl-anon-tor not running")
        sys.exit(1)

    check = run([
        "curl",
        "--socks5-hostname",
        "127.0.0.1:9050",
        "-m",
        "60",
        "https://check.torproject.org/api/ip"
    ])

    if check.returncode != 0:
        print("FAIL SOCKS route failed")
        print(check.stdout)
        print(check.stderr)
        sys.exit(1)

    try:
        data = json.loads(check.stdout)
    except Exception:
        print("FAIL invalid Tor check response")
        print(check.stdout)
        sys.exit(1)

    if data.get("IsTor") is True:
        print("RESULT PASS")
        print(json.dumps(data, indent=2))
        sys.exit(0)

    print("FAIL route is not Tor")
    print(json.dumps(data, indent=2))
    sys.exit(1)

if __name__ == "__main__":
    main()
