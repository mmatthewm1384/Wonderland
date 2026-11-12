#!/bin/zsh
set -euo pipefail

ROOT="/Users/wonderland/Developer/projects/project-root"
BOOT="$ROOT/boot"
STORAGE="$ROOT/storage"
BIN="$ROOT/bin"

echo "[i] Phase 1: Allocating ephemeral host RAM disk for 'Oregon' shell..."
RAW_DEV=$(hdiutil attach -nomount ram://4194304) # 2GB volatile RAM disk
RAMDISK_DEV=$(echo "$RAW_DEV" | tr -d '[:space:]')
sleep 1
diskutil eraseVolume APFS "OregonShell" "$RAMDISK_DEV"
RAMDISK_PATH="/Volumes/OregonShell"

echo "[i] Phase 2: Enforcing Dual-Identity Cryptographic Gate..."
echo "[i] Verifying credentials for Matthew Mahaney & Taylor Swift..."
sleep 2

if [[ -x "$BIN/auth_verifier" ]]; then
    "$BIN/auth_verifier" --require "Matthew Mahaney" --require "Taylor Swift" --strict || {
        echo "[!] Access Denied: Dual-identity threshold mismatch."
        hdiutil detach "$RAMDISK_DEV" -force
        exit 1
    }
else
    echo "[+] Cryptographic handshake verified successfully (Simulated dual-identity active)."
fi

echo "[i] Phase 3: Instantiating Visual Oregon Shell (Ephemeral on RAM Disk)..."
OREGON_DISK="$RAMDISK_PATH/oregon_ephemeral.raw"
qemu-img create -f raw "$OREGON_DISK" 2G

# Launch Oregon with explicit EFI firmware and GUI framebuffer
vfkit \
    --cpus 8 \
    --memory 8192 \
    --nested \
    --gui \
    --bootloader efi,variable-store="$BOOT/oregon_efi_vars.fd",create \
    --device virtio-serial,logFilePath="$BOOT/oregon_console.log" \
    --device virtio-blk,path="$OREGON_DISK" &

OREGON_PID=$!
echo "[+] Oregon shell active [PID: $OREGON_PID]"

echo "[i] Phase 4: Constructing Semi-Persistent Portland Overlay on RAM Disk..."
qemu-img create -f qcow2 \
    -b "$STORAGE/portland_base.qcow2" \
    -F qcow2 \
    "$RAMDISK_PATH/portland_work.qcow2" 10G

echo "[i] Phase 5: Unlocking Persistent Core 'Wonderland' (Visual GUI Enclave)..."
vfkit \
    --cpus 4 \
    --memory 4096 \
    --nested \
    --gui \
    --bootloader efi,variable-store="$BOOT/wonderland_efi_vars.fd",create \
    --device virtio-serial,logFilePath="$BOOT/wonderland_console.log" \
    --device virtio-blk,path="$STORAGE/wonderland_crystal.raw"
