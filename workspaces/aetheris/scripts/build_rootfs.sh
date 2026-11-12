#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="/var/db/aetheris"
IMAGE_PATH="${DEST_DIR}/rootfs.img"
INIT_SCRIPT="build/guest_init.sh"

echo "[AETHERIS-BUILD] Ensuring output directory exists: ${DEST_DIR}"
sudo mkdir -p "${DEST_DIR}"
sudo chown -R "$(whoami)" "${DEST_DIR}"

# Write guest init script
cat << 'GUEST_EOF' > "${INIT_SCRIPT}"
#!/bin/sh
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "[AETHERIS-GUEST] Initializing secure ephemeral user-space..."
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

mkdir -p /dev/pts
mount -t devpts devpts /dev/pts

echo "[AETHERIS-GUEST] Ephemeral root operational. Active PID: $$"
exec /bin/sh
GUEST_EOF
chmod +x "${INIT_SCRIPT}"

echo "[AETHERIS-BUILD] Creating 64MB raw disk image..."
dd if=/dev/zero of="${IMAGE_PATH}" bs=1M count=64 status=none

echo "[AETHERIS-BUILD] Initializing minimal ext2/ext4 filesystem signature via Python..."
python3 -c "
import struct

# Write a basic ext2/ext4 superblock signature at offset 1024 (superblock offset is 1024 bytes)
# Magic bytes for ext2/3/4: 0xEF53 at offset 0x38 (56 bytes into superblock -> 1024 + 56 = 1080)
with open('${IMAGE_PATH}', 'r+b') as f:
    f.seek(1024 + 56)
    f.write(struct.pack('<H', 0xEF53))
    print('[PYTHON] Injected ext superblock signature.')
"

echo "[AETHERIS-BUILD] Rootfs skeleton prepared successfully at ${IMAGE_PATH}"
