#!/usr/bin/env python3
import sys
import time
import requests

PROXIES = {
    "http": "socks5h://wl-anon-tor:9050",
    "https": "socks5h://wl-anon-tor:9050"
}

def verify_routing():
    try:
        response = requests.get(
            "https://check.torproject.org/api/ip",
            proxies=PROXIES,
            timeout=30
        )
        return response.json().get("IsTor", False)
    except Exception:
        return False

def main():
    if not verify_routing():
        sys.exit(1)

    while True:
        try:
            res = requests.get(
                "https://httpbin.org/headers",
                proxies=PROXIES,
                timeout=30
            )
            print(f"[DATA-STREAM] Successfully processed payload size: {len(res.text)} bytes", flush=True)
        except Exception:
            if not verify_routing():
                sys.exit(2)
        time.sleep(30)

if __name__ == "__main__":
    main()
