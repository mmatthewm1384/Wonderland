#!/bin/zsh

TARGET_DIR="/Users/wonderland"
echo "[*] Scanning $TARGET_DIR for Debian artifacts and container images..."

# Search patterns for compressed archives, raw disk images, and rootfs directories
find "$TARGET_DIR" \
  \( -name "*debian*" \
     -o -name "*bookworm*" \
     -o -name "*.img" \
     -o -name "*.tar" \
     -o -name "*.tar.gz" \
     -o -name "rootfs" \
     -o -name "vmlinuz*" \
     -o -name "initrd*" \
  \) \
  -not -path "*/Library/*" \
  -not -path "*/.git/*" \
  2>/dev/null

echo "[*] Scan complete."
