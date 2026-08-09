#!/usr/bin/env bash
set -euo pipefail

resolve_wl_root()
{
    if [[ -n "${WL_ROOT:-}" ]]; then
        echo "$WL_ROOT"
        return
    fi

    if command -v git >/dev/null 2>&1; then
        local ROOT
        ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
        if [[ -n "$ROOT" ]]; then
            echo "$ROOT"
            return
        fi
    fi

    local SCRIPT_PATH
    SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$(cd "$SCRIPT_PATH/../../.." && pwd)"
}

WL_ROOT="$(resolve_wl_root)"
export WL_ROOT


echo "=== Wonderland Spark VM Builder ==="

if [[ "$(uname)" == "Darwin" ]]; then

    echo "[+] macOS detected"
    echo "[+] Delegating build to Debian Spark factory VM"

    SRC="$1"
    OUT="$2"

    # Convert host Wonderland paths to VM mount paths
    SRC_VM="${SRC/$HOME\/Wonderland/\/mnt\/wonderland}"
    OUT_VM="${OUT/$HOME\/Wonderland/\/mnt\/wonderland}"

    limactl shell wonderland-debian-rootless-v1 -- bash -lc "
        set -e
        cd /mnt/wonderland
        Crystal/us/sparks/image-builder/build-vm-image-linux.sh \
        '$SRC_VM' \
        '$OUT_VM'
    "

    exit $?
fi

echo "[+] Linux mode"

exec "$(dirname "$0")/build-vm-image-linux.sh" "$@"
