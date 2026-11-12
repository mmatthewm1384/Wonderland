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
