#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DISK="${1:?runtime disk required}"
ROOTFS="${2:?rootfs required}"

TMP=$(mktemp -d)

cleanup() {
    sudo umount "$TMP/rootfs" 2>/dev/null || true
    sudo umount "$TMP/root" 2>/dev/null || true
    rm -rf "$TMP"
}

trap cleanup EXIT

echo "=== Spark Linux Runtime Population ==="

mkdir -p "$TMP/root" "$TMP/rootfs"

echo "[+] Formatting runtime disk"
sudo mkfs.ext4 -F "$RUNTIME_DISK"

echo "[+] Mounting runtime disk"
sudo mount "$RUNTIME_DISK" "$TMP/root"

echo "[+] Mounting source rootfs"
sudo mount -o loop,ro "$ROOTFS" "$TMP/rootfs"

echo "[+] Copying filesystem"

sudo cp -a \
    "$TMP/rootfs/." \
    "$TMP/root/"

echo "[+] Installing Spark identity"

sudo mkdir -p "$TMP/root/etc/wonderland"

echo "spark-runtime" | sudo tee \
    "$TMP/root/etc/wonderland/runtime-id" >/dev/null

echo "[+] Creating wonderland user"

sudo chroot "$TMP/root" /bin/sh <<'CHROOT'
adduser -D wonderland 2>/dev/null || true
mkdir -p /home/wonderland
chown wonderland:wonderland /home/wonderland
CHROOT

echo "[PASS] Spark runtime populated"

