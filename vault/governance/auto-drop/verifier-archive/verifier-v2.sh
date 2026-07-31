#!/usr/bin/env bash
set -euo pipefail

#
# Wonderland Auto-Drop Verifier v2
#
# Responsibilities:
# - Validate transaction workspace
# - Execute package-local verification
# - Never inspect repository root for package scripts
#

TYPE="${1:-package}"

if [[ -z "${WORKSPACE:-}" ]]; then
    echo "ERROR: WORKSPACE not defined"
    exit 1
fi

WORKSPACE="$(cd "$WORKSPACE" && pwd)"

echo "========== VERIFIER =========="
echo "TYPE       : $TYPE"
echo "WORKSPACE  : $WORKSPACE"
echo "PWD        : $(pwd)"
echo

if [[ ! -d "$WORKSPACE" ]]; then
    echo "ERROR: workspace missing"
    exit 1
fi


VERIFY_SCRIPT="$WORKSPACE/scripts/verify.sh"

echo "Workspace scripts:"
ls -la "$WORKSPACE/scripts" 2>/dev/null || {
    echo "ERROR: scripts directory missing"
    exit 1
}

echo

if [[ ! -f "$VERIFY_SCRIPT" ]]; then
    echo "ERROR: scripts/verify.sh missing"
    echo "EXPECTED:"
    echo "$VERIFY_SCRIPT"
    exit 1
fi


if [[ ! -x "$VERIFY_SCRIPT" ]]; then
    echo "FIX: making verify executable"
    chmod +x "$VERIFY_SCRIPT"
fi


echo "Executing package verification..."
echo

"$VERIFY_SCRIPT"

RESULT=$?

if [[ "$RESULT" -ne 0 ]]; then
    echo
    echo "VERIFICATION FAILED"
    exit "$RESULT"
fi


echo
echo "VERIFICATION PASS"
exit 0
