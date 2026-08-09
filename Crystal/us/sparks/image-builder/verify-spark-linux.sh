#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?image required}"

echo "=== Wonderland Spark Verification ==="

echo "[+] Checking image"

qemu-img info "$IMAGE"


echo
echo "[+] Checking partitions"

fdisk -l "$IMAGE"


echo
echo "[+] Checking EFI"

mkdir -p /mnt/spark-verify-efi

mount \
-o loop,offset=$((2048*512)) \
"$IMAGE" \
/mnt/spark-verify-efi


test -f /mnt/spark-verify-efi/EFI/BOOT/BOOTAA64.EFI

echo "[PASS] EFI bootloader present"


umount /mnt/spark-verify-efi


echo
echo "[+] Checking root filesystem"

mkdir -p /mnt/spark-verify-root

mount \
-o loop,offset=$((1050624*512)) \
"$IMAGE" \
/mnt/spark-verify-root


test -f /mnt/spark-verify-root/usr/local/bin/lima-guestagent

echo "[PASS] Lima guest agent present"


echo
echo "[+] Checking OpenRC services"

chroot /mnt/spark-verify-root \
/bin/sh -c "rc-update show"


umount /mnt/spark-verify-root


echo
echo "[CERTIFIED] Spark image valid"
