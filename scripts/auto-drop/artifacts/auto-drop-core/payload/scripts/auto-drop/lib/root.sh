#!/usr/bin/env bash
#
# Wonderland Auto-Drop Root Resolver
#

wl_root() {
    git rev-parse --show-toplevel
}

wl_require_root() {
    local root

    if ! root="$(wl_root 2>/dev/null)"; then
        echo "ERROR: Wonderland root not found" >&2
        return 1
    fi

    if [[ ! -d "$root" ]]; then
        echo "ERROR: Invalid Wonderland root: $root" >&2
        return 1
    fi

    printf "%s\n" "$root"
}

export -f wl_root
export -f wl_require_root
