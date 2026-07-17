#!/usr/bin/env bash
set -euo pipefail

ROOT="${WONDERLAND_ROOT:-$(pwd)}"

echo "======================================"
echo " Wonderland Registry Auto Drop-In"
echo "======================================"
echo
echo "ROOT:"
echo " $ROOT"
echo

fail=0

check() {
    local name="$1"
    local path="$2"

    if [[ -e "$ROOT/$path" ]]; then
        echo "PASS  $name"
        echo "      $path"
    else
        echo "MISS  $name"
        echo "      $path"
        fail=1
    fi
}

echo "=== CLI Registry Surface ==="

check \
"CLI registry module" \
"builder/python/wlcli/wlcli/registry.py"

check \
"CLI main entry" \
"builder/python/wlcli/wlcli/main.py"

echo
echo "=== Registry References ==="

grep -R "registry" \
    "$ROOT/builder/python/wlcli/wlcli" \
    2>/dev/null \
    | sed "s|$ROOT/||" \
    || true

echo
echo "=== Platform Registry Discovery ==="

grep -R "registry" \
    "$ROOT/builder/python/wlplatform/wlplatform" \
    2>/dev/null \
    | sed "s|$ROOT/||" \
    || true

echo
echo "=== Command Availability ==="

if command -v wl >/dev/null 2>&1; then
    if wl --help 2>/dev/null | grep -q registry; then
        echo "PASS  wl registry command exists"
    else
        echo "MISS  wl registry command missing"
    fi
else
    echo "MISS  wl command not installed"
fi

echo
echo "=== Ownership Assessment ==="

if grep -R "def.*registry" \
    "$ROOT/builder/python/wlplatform/wlplatform" \
    >/dev/null 2>&1; then

    echo "Platform registry implementation detected."
    echo
    echo "Recommended migration:"
    echo
    echo "    wl registry ..."
    echo "          ↓"
    echo "    wl platform registry ..."
else
    echo "No Platform registry handler detected."
fi

echo
echo "======================================"

if [[ $fail -eq 0 ]]; then
    echo "Registry inspection complete."
else
    echo "Registry inspection found missing components."
fi

exit 0
