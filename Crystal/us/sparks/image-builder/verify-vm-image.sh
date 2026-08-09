#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?image required}"

echo "=== Verify Spark VM ==="

fdisk -l "$IMAGE"

echo
echo "Checking GPT..."

sudo losetup --find --show --partscan "$IMAGE"

echo
echo "[PASS] Image appears partitioned."
