#!/bin/sh
# ==============================================================================
# Wonderland: Project Aetheris // Guest Ephemeral Initialization
# File: guest/scripts/init.sh
# ==============================================================================

set -euo pipefail

echo "==> [AETHERIS-GUEST] Booting ephemeral micro-VM root filesystem..."

# 1. Mount virtual pseudo-filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# 2. Establish Secure Volatile Memory Crystal (tmpfs mount)
# Configured with strict noexec/nosuid constraints where applicable, 
# or tailored execution flags depending on payload requirements.
mkdir -p /mnt/volatile
mount -t tmpfs -o size=128m,nosuid,nodev tmpfs /mnt/volatile

echo "==> [AETHERIS-GUEST] Volatile memory crystal mounted successfully (128MB RAM)."

# 3. Ingest and unpack payload passed via Virtio console/port
if [ -c /dev/vport0 ] || [ -e /dev/vport0 ]; then
    echo "==> [AETHERIS-GUEST] Extracting payload from orchestrator stream..."
    tar -xzf /dev/vport0 -C /mnt/volatile/ 2>/dev/null || true
fi

# Fallback check for mounted payload directory
if [ -d /mnt/payload ]; then
    cp -r /mnt/payload/* /mnt/volatile/
fi

# 4. Execute Isolated Workload under restricted environment variables
cd /mnt/volatile
if [ -f "./payload_binary" ]; then
    echo "==> [AETHERIS-GUEST] Executing payload binary..."
    env -i PATH="/bin:/usr/bin:/usr/local/bin" \
        AETHERIS_MODE="ephemeral" \
        ./payload_binary
else
    echo "==> [AETHERIS-GUEST] Warning: No primary payload binary found. Awaiting telemetry command."
    sleep 2
fi

# 5. Immediate Cryptographic Zeroization & Purge Sequence
echo "==> [AETHERIS-GUEST] Initiating zero-trust memory shredding..."

# Overwrite files multiple times with random data and zero-fill before unmounting
if command -v shred >/dev/null 2>&1; then
    find /mnt/volatile -type f -exec shred -u -z -n 3 {} \;
else
    # Fallback secure zero-fill wipe if coreutils shred is absent in minimal base
    find /mnt/volatile -type f -exec dd if=/dev/zero of={} bs=1M count=1 conv=fsync \; 2>/dev/null || true
    rm -rf /mnt/volatile/*
fi

# Unmount the volatile RAM boundary
umount /mnt/volatile
echo "==> [AETHERIS-GUEST] Memory crystal wiped. Powering off instance."

# Force immediate hypervisor exit
poweroff -f
