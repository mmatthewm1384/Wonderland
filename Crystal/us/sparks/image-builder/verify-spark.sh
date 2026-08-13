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

    [[ "$IMAGE" == "$HOME/Wonderland/"* ]] || {
        echo "[FAIL] image must be inside WL_ROOT"
        exit 1
    }

    IMAGE_VM="/mnt/wonderland/${IMAGE#$HOME/Wonderland/}"

    SSH_CONFIG="$HOME/.lima/wonderland-debian-rootless-v1/ssh.config"
    SSH_HOST="lima-wonderland-debian-rootless-v1"

    [[ -f "$SSH_CONFIG" ]] || {
        echo "[FAIL] Lima SSH config not found: $SSH_CONFIG"
        exit 1
    }

    ssh -F "$SSH_CONFIG" \
        "$SSH_HOST" \
        "cd /mnt/wonderland && sudo Crystal/us/sparks/image-builder/verify-spark-linux.sh '$IMAGE_VM'"

    exit $?
fi


exec "$(dirname "$0")/verify-spark-linux.sh" "$@"
