#!/bin/zsh
set -euo pipefail

ASSETS_DIR="/Users/Wonderland/Wonderland/workspaces/aetheris/assets"
IMG_PATH="$ASSETS_DIR/rootfs.img"
MOUNT_DIR="/mnt/rootfs"

if [[ ! -f "$IMG_PATH" ]]; then
    echo "[-] Error: rootfs.img not found at $IMG_PATH" >&2
    exit 1
fi

echo "[*] Launching container to mount and inspect rootfs.img..."

# Run a privileged container with loop device support to mount the raw ext4 image
podman run --rm -it --privileged \
  -v "$ASSETS_DIR:/workspace:z" \
  debian:bookworm-slim bash -c "
    set -e
    echo '[*] Creating mount point inside container...'
    mkdir -p /mnt/target
    
    echo '[*] Mounting raw ext4 rootfs.img...'
    mount -o loop /workspace/rootfs.img /mnt/target
    
    echo '[+] Successfully mounted rootfs.img at /mnt/target'
    echo '[*] Root directory contents:'
    ls -la /mnt/target
    
    # Example modification: Ensure /boot or /EFI/BOOT directories exist
    mkdir -p /mnt/target/EFI/BOOT
    
    echo ''
    echo '=================================================='
    echo 'You are now inside the rootfs inspection shell.'
    echo 'Modify files, add EFI loaders, or check packages here.'
    echo 'Type \"exit\" when finished to unmount and save.'
    echo '=================================================='
    echo ''
    
    bash || true
    
    echo '[*] Unmounting filesystem...'
    umount /mnt/target
    echo '[+] Changes successfully committed to rootfs.img.'
  "
