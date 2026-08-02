#!/usr/bin/env bash
set -euo pipefail

echo "=== NETWORK VERIFICATION ==="

echo
echo "Kernel forwarding:"
sysctl net.ipv4.ip_forward

echo
echo "Rootless network:"
nerdctl info | grep -E "rootless|Network|Security" || true

echo
echo "Listening ports:"
ss -tulpn || true

echo
echo "Network verification complete"
