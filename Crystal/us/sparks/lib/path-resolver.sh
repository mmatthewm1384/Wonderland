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

    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
}


spark_artifact_path()
{
    local artifact="$1"

    echo "${WL_ROOT}/${artifact}"
}


export WL_ROOT="$(resolve_wl_root)"
