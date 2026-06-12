#!/usr/bin/env bash
# core/repair.sh: Idempotent environment remediation agent

set -euo pipefail

VENV_DIR="${WONDERLAND_ROOT}/core/.venv"
PID_FILE="${WONDERLAND_ROOT}/core/.bus.pid"

echo "=== [REPAIR MODE] Executing Idempotent Rectification ==="

# 1. Remediate isolated execution layers
if [ ! -d "$VENV_DIR" ]; then
    echo "[*] Constructing virtual environment runtime locally..."
    python3 -m venv "$VENV_DIR"
fi

# Ensure fundamental capabilities match
"${VENV_DIR}/bin/pip" install --upgrade pip >/dev/null 2>&1 || true

# 2. Re-establish ledger baseline
"${VENV_DIR}/bin/python" "${WONDERLAND_ROOT}/core/mesh.py"

# 3. Recover asynchronous background processes if crashed
if [ ! -f "$PID_FILE" ] || ! kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "[*] Spawning broken event bus messaging loop..."
    "${WONDERLAND_ROOT}/core/bus.sh" init
fi

# 4. Clean up mock failure injections
if [ -f "${WONDERLAND_ROOT}/core/.mock_fail" ]; then
    rm -f "${WONDERLAND_ROOT}/core/.mock_fail"
    echo "[*] Flushed existing chaos flags."
fi

echo "[+] Repair successfully executed. Rerunning verification state next."
