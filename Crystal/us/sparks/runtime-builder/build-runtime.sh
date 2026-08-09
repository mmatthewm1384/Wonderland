#!/usr/bin/env bash
set -euo pipefail

SPARK_NAME="${1:?Usage: $0 <spark-name>}"

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

SPARK_DIR="$WL_ROOT/Crystal/us/sparks"

IMAGE_DIR="$SPARK_DIR/images/alpine-spark-v1"
ARTIFACT_DIR="$IMAGE_DIR/artifacts"

ROOTFS="$ARTIFACT_DIR/alpine-spark-rootfs-v1-aarch64.ext4.img"

RUNTIME_DIR="$SPARK_DIR/runtime"

RUNTIME_DISK="$RUNTIME_DIR/${SPARK_NAME}-disk.img"

echo "=== Wonderland Spark Runtime Builder ==="

if [[ ! -f "$ROOTFS" ]]; then
    echo "[FAIL] Missing rootfs:"
    echo "$ROOTFS"
    exit 1
fi

mkdir -p "$RUNTIME_DIR"

SIZE="10G"

echo "[+] Creating runtime disk"
echo "    Output: $RUNTIME_DISK"
echo "    Size:   $SIZE"

qemu-img create \
    -f raw \
    "$RUNTIME_DISK" \
    "$SIZE"

echo "[+] Copying Spark filesystem"

TMP=$(mktemp -d)

cleanup() {
    sudo umount "$TMP/root" 2>/dev/null || true
    rmdir "$TMP/root" 2>/dev/null || true
}

trap cleanup EXIT

mkdir -p "$TMP/root"

echo "[+] Delegating Linux population"

ssh wonderland@127.0.0.1 \
"~/Wonderland/Crystal/us/sparks/runtime-builder/linux-populate-runtime.sh \
$RUNTIME_DISK \
$ROOTFS"

echo "[+] Installing runtime identity"

sudo mkdir -p "$TMP/root/home/wonderland/.ssh"

sudo chroot "$TMP/root" /bin/sh <<EOF
adduser -D wonderland || true
mkdir -p /home/wonderland/.ssh
chmod 700 /home/wonderland/.ssh
EOF

echo "[PASS] Runtime disk created"

echo "$RUNTIME_DISK"
