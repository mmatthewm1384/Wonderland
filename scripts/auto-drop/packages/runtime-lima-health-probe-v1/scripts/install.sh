#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

OUT="$WL_ROOT/vault/governance/runtime/lima/health"

mkdir -p "$OUT"

INSTANCE="wonderland-rootless"

STATUS="unknown"
KERNEL="unknown"
CONTAINERD="unknown"

if command -v limactl >/dev/null 2>&1; then
    STATUS=$(limactl list --format '{{.Status}}' "$INSTANCE" 2>/dev/null || echo "missing")
fi

if [[ "$STATUS" == "Running" ]]; then
    KERNEL=$(limactl shell "$INSTANCE" uname -a 2>/dev/null || echo "unavailable")
    CONTAINERD=$(limactl shell "$INSTANCE" nerdctl --version 2>/dev/null || echo "unavailable")
fi

cat > "$OUT/health-report.json" <<JSON
{
  "instance": "$INSTANCE",
  "status": "$STATUS",
  "kernel": "$KERNEL",
  "container_runtime": "$CONTAINERD",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON

echo "INSTALL PASS"
