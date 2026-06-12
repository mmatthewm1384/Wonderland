#!/usr/bin/env bash
# core/doctor.sh: Read-only health validator (Mandatory Doctor Mode)

set -euo pipefail

PID_FILE="${WONDERLAND_ROOT}/core/.bus.pid"
VENV_DIR="${WONDERLAND_ROOT}/core/.venv"
FAILED=0

echo "=== [DOCTOR MODE] Evaluating System Integrity ==="

# 1. Verify Event Bus Lifecycle
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "[OK] Event Bus process tree is alive."
else
    echo "[FAIL] Event Bus daemon is missing or unresponsive."
    FAILED=1
fi

# 2. Verify Python Isolation Setup
if [ -x "${VENV_DIR}/bin/python" ]; then
    echo "[OK] Venv python engine present."
else
    echo "[FAIL] Python environment isolated structure missing."
    FAILED=1
fi

# 3. Verify Cryptographic Ledger State
if [ -x "${VENV_DIR}/bin/python" ]; then
    if "${VENV_DIR}/bin/python" "${WONDERLAND_ROOT}/core/mesh.py" verify; then
        echo "[OK] State ledger hashes trace cleanly to genesis."
    else
        echo "[FAIL] State ledger hash mismatch or verification broke."
        FAILED=1
    fi
else
    echo "[FAIL] Skipping ledger validation due to missing python venv executable."
    FAILED=1
fi

exit "$FAILED"
