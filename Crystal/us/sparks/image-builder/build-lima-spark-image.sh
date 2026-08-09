#!/usr/bin/env bash
set -euo pipefail

SOURCE="${1:?source rootfs image required}"
OUTPUT="${2:?output Lima image required}"

WORK="$(mktemp -d)"

cleanup() {
    sudo umount "$WORK/root" 2>/dev/null || true
    rm -rf "$WORK"
}
trap cleanup EXIT

mkdir -p "$WORK/root"

echo "=== Wonderland Lima Spark Image Builder ==="

echo "[+] Creating image"
qemu-img convert \
    -f raw \
    -O raw \
    "$SOURCE" \
    "$OUTPUT"

echo "[+] Checking filesystem"

sudo mount -o loop "$OUTPUT" "$WORK/root"

echo "[+] Installing Lima requirements"

sudo chroot "$WORK/root" /bin/sh <<'EOF'
set -eux

apk update

apk add --no-cache \
    openssh \
    ca-certificates \
    bash \
    curl \
    git \
    jq \
    nerdctl \
    containerd \
    runc \
    fuse-overlayfs \
    slirp4netns

ssh-keygen -A

rc-update add sshd default || true

mkdir -p /etc/lima

echo "spark-runtime" > /etc/hostname

EOF

echo "[+] Spark Lima image complete"

sudo umount "$WORK/root"

echo "$OUTPUT"
