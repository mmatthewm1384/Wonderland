#!/usr/bin/env bash

set -euo pipefail

VM="${1:-wonderland-rootless}"

echo "WONDERLAND LIMA BASELINE CHECK"
echo "=============================="

echo

echo "[1] VM state"
limactl list | grep "$VM"

echo
echo "[2] Mount policy"

MOUNTS=$(limactl shell "$VM" mount)

if echo "$MOUNTS" | grep -q "/Users"; then
    echo "FAIL: Host home mount detected"
    exit 1
fi

if echo "$MOUNTS" | grep -q "/mnt/shared"; then
    echo "PASS: Shared mount present"
else
    echo "FAIL: Missing /mnt/shared"
    exit 1
fi

echo
echo "[3] Rootless containerd"

if limactl shell "$VM" nerdctl info | grep -qi rootless; then
    echo "PASS: Rootless runtime"
else
    echo "FAIL: Rootless runtime missing"
    exit 1
fi

echo
echo "[4] AppArmor"

if limactl shell "$VM" sudo aa-status | grep -q nerdctl-default; then
    echo "PASS: nerdctl AppArmor profile"
else
    echo "FAIL: AppArmor profile missing"
    exit 1
fi

echo
echo "CERTIFIED"
