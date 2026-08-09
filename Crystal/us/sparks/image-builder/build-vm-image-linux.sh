#!/usr/bin/env bash
set -euo pipefail

echo "=== Wonderland Spark VM Linux Builder ==="

OUT_IMAGE="${2:?output image required}"

EFI_SIZE="+512M"

TMP="/tmp/spark-build"

echo "[+] Cleaning previous mounts"

sudo umount -lf "$TMP/root/boot/efi" 2>/dev/null || true
sudo umount -lf "$TMP/root/dev/pts" 2>/dev/null || true
sudo umount -lf "$TMP/root/dev" 2>/dev/null || true
sudo umount -lf "$TMP/root/proc" 2>/dev/null || true
sudo umount -lf "$TMP/root/sys" 2>/dev/null || true

sudo umount -lf "$TMP/base" 2>/dev/null || true
sudo umount -lf "$TMP/root" 2>/dev/null || true
sudo umount -lf "$TMP/efi" 2>/dev/null || true


cleanup() {
    set +e

    echo "[+] Cleaning mounts"

    sudo umount -lf "$TMP/root/boot/efi" 2>/dev/null || true
    sudo umount -lf "$TMP/root/dev/pts" 2>/dev/null || true
    sudo umount -lf "$TMP/root/dev" 2>/dev/null || true
    sudo umount -lf "$TMP/root/proc" 2>/dev/null || true
    sudo umount -lf "$TMP/root/sys" 2>/dev/null || true

    sudo umount -lf "$TMP/base" 2>/dev/null || true
    sudo umount -lf "$TMP/root" 2>/dev/null || true
    sudo umount -lf "$TMP/efi" 2>/dev/null || true

    if [ -n "${LOOP:-}" ]; then
        sudo losetup -d "$LOOP" 2>/dev/null || true
    fi
}


trap cleanup EXIT


rm -f "$OUT_IMAGE"

mkdir -p "$(dirname "$OUT_IMAGE")"


echo "[+] Creating raw VM disk"

qemu-img create -f raw "$OUT_IMAGE" 10G


echo "[+] Creating GPT"

sudo sgdisk \
-n1:2048:${EFI_SIZE} \
-t1:ef00 \
-n2:0:0 \
-t2:8300 \
"$OUT_IMAGE"


echo "[+] Attaching loop"

LOOP=$(sudo losetup --find --show --partscan "$OUT_IMAGE")

sleep 2


echo "[+] Formatting"

sudo mkfs.vfat "${LOOP}p1"

sudo mkfs.ext4 -F "${LOOP}p2"


mkdir -p "$TMP/efi" "$TMP/root" "$TMP/base"


sudo mount "${LOOP}p1" "$TMP/efi"

sudo mount "${LOOP}p2" "$TMP/root"


echo "[+] Mounting Alpine source"

ALPINE_ROOTFS="Crystal/us/sparks/images/alpine-spark-v1/artifacts/alpine-spark-rootfs-v1-aarch64.ext4.img"

sudo mountpoint -q "$TMP/base" || \
sudo mount -o loop "$ALPINE_ROOTFS" "$TMP/base"


echo "[+] Copying Alpine"

sudo rsync -aHAX \
"$TMP/base/" \
"$TMP/root/"


echo "[+] Installing packages"

sudo chroot "$TMP/root" /bin/sh <<'EOF'

apk add --no-cache openrc

apk add --no-scripts --no-cache \
    grub \
    grub-efi \
    openssh \
    bash \
    linux-virt

ssh-keygen -A

mkdir -p /run/openrc

rc-update add networking boot || true
rc-update add sshd default || true

EOF

sudo chroot "$TMP/root" /bin/sh <<'EOF'

update-extlinux || true

EOF


echo "[+] Installing Lima guest agent"

sudo mkdir -p "$TMP/root/usr/local/bin"
sudo mkdir -p "$TMP/root/etc/init.d"

LIMA_AGENT=""

for candidate in \
    "/usr/local/bin/lima-guestagent" \
    "/run/lima-guestagent"
do
    if [ -f "$candidate" ]; then
        LIMA_AGENT="$candidate"
        break
    fi
done

if [ -n "$LIMA_AGENT" ]; then
    echo "[+] Copying lima-guestagent from $LIMA_AGENT"

    sudo cp "$LIMA_AGENT" \
        "$TMP/root/usr/local/bin/lima-guestagent"

    sudo chmod 0755 \
        "$TMP/root/usr/local/bin/lima-guestagent"
else
    echo "[ERROR] lima-guestagent missing"
    exit 1
fi


echo "[+] Creating OpenRC Lima service"

sudo tee "$TMP/root/etc/init.d/lima-guestagent" >/dev/null <<'EOF'
#!/sbin/openrc-run

name="lima-guestagent"
description="Lima guest agent"

command="/usr/local/bin/lima-guestagent"
command_background="yes"
pidfile="/run/lima-guestagent.pid"

depend() {
    need networking
}

start_pre() {
    checkpath --directory /run
}
EOF

sudo chmod 0755 "$TMP/root/etc/init.d/lima-guestagent"


echo "[+] Enabling services"

sudo chroot "$TMP/root" /bin/sh <<'EOF'
mkdir -p /run/openrc

rc-update add networking boot || true
rc-update add sshd default || true
rc-update add lima-guestagent default || true
EOF


echo "[+] Installing EFI"

sudo mount --bind /dev "$TMP/root/dev"
sudo mount --bind /dev/pts "$TMP/root/dev/pts"
sudo mount --bind /proc "$TMP/root/proc"
sudo mount --bind /sys "$TMP/root/sys"


sudo mkdir -p "$TMP/root/boot/efi"

sudo mount --bind "$TMP/efi" "$TMP/root/boot/efi"


sudo chroot "$TMP/root" grub-install \
--target=arm64-efi \
--efi-directory=/boot/efi \
--bootloader-id=Wonderland \
--removable


sudo chroot "$TMP/root" grub-mkconfig \
-o /boot/grub/grub.cfg

echo "[PASS] Spark VM image created"
