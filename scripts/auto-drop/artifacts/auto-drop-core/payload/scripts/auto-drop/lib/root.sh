#!/usr/bin/env bash

set -euo pipefail

if [[ -n "${WL_ROOT:-}" ]]; then
    export WL_ROOT
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WL_ROOT="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"

export WL_ROOT
