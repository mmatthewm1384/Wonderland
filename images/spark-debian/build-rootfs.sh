#!/usr/bin/env bash
set -euo pipefail

echo "Installing build dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq && apt-get install -y -qq debootstrap e2fsprogs jq curl wget git >/dev/null

echo "Bootstrapping Debian Bookworm in container-local temp dir..."
debootstrap --arch=arm64 bookworm /tmp/rootfs http://deb.debian.org/debian/

echo "Mounting virtual filesystems..."
mount -t proc none /tmp/rootfs/proc
mount -t sysfs none /tmp/rootfs/sys
mount --bind /dev /tmp/rootfs/dev
mount --bind /dev/pts /tmp/rootfs/dev/pts
trap "umount -lf /tmp/rootfs/dev/pts /tmp/rootfs/dev /tmp/rootfs/sys /tmp/rootfs/proc 2>/dev/null || true" EXIT

cat << 'APT_EOF' > /tmp/rootfs/etc/apt/sources.list
deb http://deb.debian.org/debian bookworm main contrib non-free
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
deb http://security.debian.org/debian-security bookworm-security main contrib non-free
APT_EOF

chroot /tmp/rootfs apt-get update -qq
chroot /tmp/rootfs apt-get install -y -qq linux-image-arm64 initramfs-tools systemd systemd-sysv systemd-resolved openssh-server e2fsprogs jq curl wget git >/dev/null
chroot /tmp/rootfs systemctl enable systemd-networkd systemd-networkd-wait-online || true

if [ -n "${SSH_PUBKEY:-}" ]; then
    mkdir -p /tmp/rootfs/root/.ssh
    echo "$SSH_PUBKEY" > /tmp/rootfs/root/.ssh/authorized_keys
    chmod 700 /tmp/rootfs/root/.ssh
    chmod 600 /tmp/rootfs/root/.ssh/authorized_keys
fi

mkdir -p /tmp/rootfs/var/lib/tailscale
echo "/dev/vdb /var/lib/tailscale ext4 defaults 0 2" >> /tmp/rootfs/etc/fstab

echo "Creating rootfs ext4 image on host mount (/build)..."
truncate -s 2G /build/debian-bookworm-vm-rootfs.ext4
mkfs.ext4 -F /build/debian-bookworm-vm-rootfs.ext4
mkdir -p /mnt/ext4
mount -o loop /build/debian-bookworm-vm-rootfs.ext4 /mnt/ext4
cp -a /tmp/rootfs/. /mnt/ext4/
umount /mnt/ext4
echo "Rootfs ext4 image generated successfully."
