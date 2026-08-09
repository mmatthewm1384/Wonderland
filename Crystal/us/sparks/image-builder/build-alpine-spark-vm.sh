#!/usr/bin/env bash
set -euo pipefail

echo "=== Alpine Spark VM Image Builder ==="

ROOT="${WL_ROOT:-$HOME/Wonderland}"

SPARK_DIR="$ROOT/Crystal/us/sparks"

RUNTIME="${1:?runtime disk required}"

MOUNT="/tmp/spark-build"

if [[ ! -f "$RUNTIME" ]]; then
    echo "[FAIL] Missing runtime image:"
    echo "$RUNTIME"
    exit 1
fi

echo "[+] Preparing mount"

sudo mkdir -p "$MOUNT"

cleanup() {
    sudo umount "$MOUNT" 2>/dev/null || true
}

trap cleanup EXIT

sudo mount -t ext4 -o loop "$RUNTIME" "$MOUNT"

echo "[+] Installing Alpine boot packages"

sudo cp /etc/resolv.conf "$MOUNT/etc/resolv.conf"

sudo chroot "$MOUNT" /bin/sh <<'CHROOT'
set -e

apk update

apk add \
    linux-virt \
    mkinitfs \
    grub \
    grub-efi \
    efibootmgr \
    openssh \
    openrc

rc-update add sshd default || true
rc-update add networking boot || true

mkdir -p /boot

mkinitfs \
    -o /boot/initramfs-virt \
    $(ls /lib/modules | tail -1)

CHROOT

echo "[+] Creating boot structure"

sudo mkdir -p "$MOUNT/boot/efi"

echo "[+] Creating Spark identity"

sudo mkdir -p "$MOUNT/etc/wonderland"

cat <<EOF | sudo tee "$MOUNT/etc/wonderland/spark-id" >/dev/null
spark-runtime
builder=alpine-spark-v1
EOF

echo "[+] Installing bootloader"

sudo chroot "$MOUNT" /bin/sh <<'CHROOT'
set -e

grub-install \
 --target=arm64-efi \
 --efi-directory=/boot/efi \
 --bootloader-id=alpine \
 --removable || true

grub-mkconfig \
 -o /boot/grub/grub.cfg || true

CHROOT

echo "[PASS] Spark VM image prepared"
