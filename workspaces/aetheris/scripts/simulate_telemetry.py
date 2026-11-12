#!/usr/bin/env python3
"""
Wonderland IPC Telemetry Stream Simulator
Continuously broadcasts JSON-encoded TelemetryLogEntry frames to wonderland.sock.
"""

import json
import socket
import sys
import time
import uuid
from datetime import datetime

SOCKET_PATH = "/Users/wonderland/Library/Caches/wonderland/wonderland.sock"

SOURCES = ["DAEMON", "SPARK", "CRYSTAL", "SECURITY", "VECTOR", "CORE"]
MESSAGES = [
    "SIMD vector index partition synchronized successfully.",
    "Memory crystal cryptographic seal verified.",
    "Volatile spark execution cycle completed.",
    "Micro-hypervisor state checkpoint persisted to Crystal memory.",
    "IPC pipeline channel active with nominal latency.",
]


def main():
    print(f"[*] Starting Wonderland telemetry simulator targeting: {SOCKET_PATH}")
    try:
        while True:
            try:
                with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
                    sock.connect(SOCKET_PATH)
                    print("[+] Connected to daemon socket. Streaming telemetry frames...")

                    idx = 0
                    while True:
                        entry = {
                            "id": str(uuid.uuid4()),
                            "timestamp": datetime.now().strftime("%H:%M:%S"),
                            "source": SOURCES[idx % len(SOURCES)],
                            "message": MESSAGES[idx % len(MESSAGES)],
                        }

                        payload = json.dumps(entry) + "\n"
                        sock.sendall(payload.encode("utf-8"))
                        print(
                            f"-> Dispatched [{entry['timestamp']}] {entry['source']}: {entry['message']}"
                        )

                        idx += 1
                        time.sleep(2.5)

            except (ConnectionRefusedError, FileNotFoundError):
                print("[-] Socket unavailable or daemon offline. Retrying in 3 seconds...")
                time.sleep(3.0)
            except BrokenPipeError:
                print("[-] Connection lost. Re-establishing socket binding...")
                time.sleep(1.0)
    except KeyboardInterrupt:
        print("\n[*] Telemetry simulator terminated cleanly.")
        sys.exit(0)


if __name__ == "__main__":
    main()
