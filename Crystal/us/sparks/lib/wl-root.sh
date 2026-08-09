#!/usr/bin/env bash

resolve_wl_root()
{
    if [[ -n "${WL_ROOT:-}" ]]; then
        echo "$WL_ROOT"
        return
    fi

    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
        return
    fi

    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
}

export WL_ROOT="$(resolve_wl_root)"
