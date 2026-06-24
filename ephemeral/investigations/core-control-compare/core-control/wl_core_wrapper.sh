#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
VENV_DIR="${SCRIPT_DIR}/.venv"

# Automated localized environment setup with zero global runtime impact
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
    "$VENV_DIR/bin/pip" install --upgrade pip -q
    if [ -f "${SCRIPT_DIR}/requirements.txt" ] && [ -s "${SCRIPT_DIR}/requirements.txt" ]; then
        "$VENV_DIR/bin/pip" install -r "${SCRIPT_DIR}/requirements.txt" -q
    fi
fi

# Execute entry point
exec "$VENV_DIR/bin/python" "${SCRIPT_DIR}/control.py" "$@"
