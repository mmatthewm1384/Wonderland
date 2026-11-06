#!/bin/zsh
set -euo pipefail

# ====================================================================
# TaylorZone Tailscale ACL API Deployment Controller
# ====================================================================

POLICY_FILE="${1:-/Users/Wonderland/wonderland/.config/tailscale/policy.hujson}"
# Tailnet name (e.g., example.com, user.github, or '-' for default tailnet of API key owner)
TAILNET="${TAILNET:--}"
TAILSCALE_API_KEY="${TAILSCALE_API_KEY:-}"

log_info() { echo "[+] $1"; }
log_err() { echo "[-] $1" >&2; }

if [[ ! -f "$POLICY_FILE" ]]; then
    log_err "Policy file not found at: $POLICY_FILE"
    exit 1
fi

if [[ -z "$TAILSCALE_API_KEY" ]]; then
    log_err "TAILSCALE_API_KEY environment variable is not set."
    echo "Usage: TAILSCALE_API_KEY='tskey-api-...' $0 [path_to_policy.hujson]"
    exit 1
fi

log_info "Reading policy specification from $POLICY_FILE..."
POLICY_CONTENT=$(cat "$POLICY_FILE")

# Validate JSON structure locally via python prior to transmission
log_info "Validating policy JSON syntax locally..."
python3 - << 'EOF' "$POLICY_CONTENT"
import sys, json

content = sys.argv[1]
# Strip single-line comments for HuJSON evaluation if necessary
lines = [line for line in content.splitlines() if not line.strip().startswith("//")]
clean_json = "\n".join(lines)

try:
    json.loads(clean_json)
    print("[+] JSON syntax verification passed.")
except Exception as e:
    print(f"[-] Invalid JSON in policy file: {e}", file=sys.stderr)
    sys.exit(1)
EOF

log_info "Deploying ACL update to Tailscale REST API endpoint..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    "https://api.tailscale.com/api/v2/tailnet/${TAILNET}/acl" \
    -u "${TAILSCALE_API_KEY}:" \
    -H "Content-Type: application/json" \
    -d "$POLICY_CONTENT")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" -ge 200 && "$HTTP_CODE" -lt 300 ]]; then
    log_info "Successfully updated Tailscale ACL policy live! (HTTP $HTTP_CODE)"
else
    log_err "Failed to update ACL policy. HTTP Status: $HTTP_CODE"
    echo "$BODY" >&2
    exit 1
fi
