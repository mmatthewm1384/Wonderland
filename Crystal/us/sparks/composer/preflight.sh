#!/usr/bin/env bash
set -euo pipefail

SPARK_NAME="${1:?spark name required}"

echo "=== Spark Preflight ==="

if limactl list --format '{{.Name}}' | grep -q "^${SPARK_NAME}$"; then
    echo "[+] Removing existing Spark instance"
    limactl stop "$SPARK_NAME" 2>/dev/null || true
    limactl delete "$SPARK_NAME"
fi

if limactl list --format '{{.Name}}' | grep -q "^${SPARK_NAME}.lima$"; then
    echo "[+] Removing stale Lima artifact"
    limactl delete "${SPARK_NAME}.lima" || true
fi

echo "[PASS] Spark preflight complete"
