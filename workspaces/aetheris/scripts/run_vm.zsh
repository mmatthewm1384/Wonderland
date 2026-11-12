#!/bin/zsh
set -euo pipefail

ASSETS_DIR="/Users/Wonderland/Wonderland/workspaces/aetheris/assets"
SERIAL_LOG="/tmp/vfkit_serial.log"

# Ensure all boot assets exist
if [[ ! -f "$ASSETS_DIR/Image" || ! -f "$ASSETS_DIR/initramfs-virt.img" || ! -f "$ASSETS_DIR/rootfs.img" ]]; then
    echo "[-] Error: Required VM assets (Image, initramfs-virt.img, rootfs.img) not found in $ASSETS_DIR" >&2
    exit 1
fi

# Clear previous log
rm -f "$SERIAL_LOG"
touch "$SERIAL_LOG"

echo "[*] Launching vfkit micro-VM with native NAT networking..."
vfkit \
  --cpus 2 \
  --memory 2048 \
  --kernel "$ASSETS_DIR/Image" \
  --initrd "$ASSETS_DIR/initramfs-virt.img" \
  --kernel-cmdline "console=hvc0 root=/dev/vda rw panic=1" \
  --device virtio-blk,path="$ASSETS_DIR/rootfs.img" \
  --device virtio-net,nat,portForward=2222:22 \
  --device virtio-fs,sharedDir="/Users/Wonderland/Wonderland/workspaces/aetheris/assets",mountTag="workspace-share" \
  --device virtio-serial,logFilePath="$SERIAL_LOG" &

VM_PID=$!
echo "[+] VM started with PID $VM_PID. Tailing serial log..."

# Trap exit to clean up background VM process if script is interrupted
trap "kill $VM_PID 2>/dev/null" EXIT

# Tail the serial log in real time
tail -f "$SERIAL_LOG"
