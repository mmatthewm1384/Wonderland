#!/bin/zsh
set -euo pipefail

# ====================================================================
# TaylorZone Tailscale ACL Validation Suite
# ====================================================================

POLICY_FILE="${1:-/Users/Wonderland/wonderland/taylorzone/policy.hujson}"
ERRORS=0
WARNINGS=0

log_pass() { echo "  [PASS] $1"; }
log_fail() { echo "  [FAIL] $1" >&2; ((ERRORS++)); }

echo "=== Beginning Tailscale ACL Policy Verification ==="
echo "[+] Target Policy File: $POLICY_FILE"
echo ""

if [[ ! -f "$POLICY_FILE" ]]; then
    echo "[-] Error: Tailscale policy file not found at: $POLICY_FILE" >&2
    exit 1
fi

if ! command -v tailscale &>/dev/null; then
    echo "[-] Error: 'tailscale' CLI tool is not installed or not in PATH." >&2
    exit 1
fi

# Define test matrix: Source | Target | Port | Expected Outcome (accept|deny)
TEST_CASES=(
    "matthewandtaylors@icloud.com:tay.tswift1989@gmail.com:22000:accept:Syncthing P2P Data (Local -> Remote)"
    "tay.tswift1989@gmail.com:matthewandtaylors@icloud.com:22000:accept:Syncthing P2P Data (Remote -> Local)"
    "matthewandtaylors@icloud.com:tay.tswift1989@gmail.com:21027:accept:Syncthing Discovery (Local -> Remote)"
    "tay.tswift1989@gmail.com:matthewandtaylors@icloud.com:21027:accept:Syncthing Discovery (Remote -> Local)"
    "matthewandtaylors@icloud.com:tay.tswift1989@gmail.com:8384:deny:Syncthing Web GUI Exposure"
    "tay.tswift1989@gmail.com:matthewandtaylors@icloud.com:8384:deny:Syncthing Web GUI Isolation"
    "matthewandtaylors@icloud.com:tay.tswift1989@gmail.com:22:deny:SSH Remote Execution"
    "tay.tswift1989@gmail.com:matthewandtaylors@icloud.com:22:deny:SSH Host Ingress"
)

echo "[+] Running Tailscale ACL Test Rules..."

for test_case in "${TEST_CASES[@]}"; do
    IFS=":" read -r SRC DST PORT EXPECTED DESC <<< "$test_case"
    
    # Run tailscale acl test
    # Note: tailscale acl test returns 0 when assertion matches, non-zero when test fails.
    if [[ "$EXPECTED" == "accept" ]]; then
        if tailscale acl test --file="$POLICY_FILE" --src="$SRC" --dst="$DST:$PORT" &>/dev/null; then
            log_pass "ACCEPTED: $DESC ($SRC -> $DST:$PORT)"
        else
            log_fail "EXPECTED ACCEPT BUT DENIED: $DESC ($SRC -> $DST:$PORT)"
        fi
    elif [[ "$EXPECTED" == "deny" ]]; then
        if ! tailscale acl test --file="$POLICY_FILE" --src="$SRC" --dst="$DST:$PORT" &>/dev/null; then
            log_pass "DENIED: $DESC ($SRC -> $DST:$PORT)"
        else
            log_fail "EXPECTED DENY BUT ACCEPTED: $DESC ($SRC -> $DST:$PORT)"
        fi
    fi
done

echo ""
echo "=== ACL Validation Summary ==="
echo "Errors: $ERRORS"

if [[ $ERRORS -gt 0 ]]; then
    echo "[-] Policy test failed with $ERRORS violation(s). Review policy.hujson rules."
    exit 1
else
    echo "[+] All Tailscale ACL rules verified successfully!"
    exit 0
fi
