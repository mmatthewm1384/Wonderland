#!/bin/bash
set -e

SOCKET_PATH="/Users/wonderland/Library/Caches/wonderland/wonderland.sock"

echo "=== Wonderland: Project Aetheris IPC Pipeline Verification ==="

if [ ! -S "$SOCKET_PATH" ]; then
    echo "[-] ERROR: Unix domain socket not found or not active at $SOCKET_PATH."
    echo "[!] Please ensure the Aetheris daemon is running: cargo run --bin aetheris-telemetry"
    exit 1
fi

echo "[+] Active Unix domain socket verified at $SOCKET_PATH"
echo "[+] Dispatching test telemetry payload..."

if command -v nc &> /dev/null; then
    echo '{"action":"ping","target":"ipc_pipeline"}' | nc -U "$SOCKET_PATH" && echo "[+] Payload delivered successfully."
else
    echo "[!] nc (netcat) utility not found."
fi
