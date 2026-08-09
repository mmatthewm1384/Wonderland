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


IMAGE="$1"

if [[ "$(uname)" == "Darwin" ]]; then

    echo "[+] macOS detected"
    echo "[+] Delegating verification to Spark factory VM"

    IMAGE_VM="/mnt/wonderland/${IMAGE#$HOME/Wonderland/}"

    limactl shell wonderland-debian-rootless-v1 -- bash -lc "
        cd /mnt/wonderland
        sudo Crystal/us/sparks/image-builder/verify-spark-linux.sh '$IMAGE_VM'
    "

    exit $?
fi


exec "$(dirname "$0")/verify-spark-linux.sh" "$@"
