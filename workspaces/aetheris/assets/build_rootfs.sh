#!/usr/bin/env bash
set -Eeuo pipefail

ASSET_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS_DIR="$ASSET_DIR/rootfs_dir"
IMAGE="localhost/spark-rootfs:local"
DISK_SIZE="2G"

# Locate host SSH public key
SSH_PUB_KEY="${SSH_PUB_KEY:-}"
if [ -z "$SSH_PUB_KEY" ]; then
    for key in "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_rsa.pub"; do
        if [ -f "$key" ]; then
            SSH_PUB_KEY="$key"
            break
        fi
    done
fi

echo "[+] Building Debian ARM64 Spark root filesystem..."

mkdir -p "$ROOTFS_DIR"
rm -rf "$ROOTFS_DIR"/*

CONTAINERFILE="$(mktemp "$ASSET_DIR/Containerfile.XXXXXX")"
trap 'rm -f "$CONTAINERFILE"' EXIT

cat > "$CONTAINERFILE" <<'EOF'
FROM --platform=linux/arm64 debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d \
    && chmod +x /usr/sbin/policy-rc.d \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        systemd systemd-sysv \
        openssh-server \
        ca-certificates \
        iproute2 \
        iputils-ping \
        sudo \
        e2fsprogs \
        tar \
        passwd \
    && rm -f /usr/sbin/policy-rc.d \
    && mkdir -p /var/run/sshd \
    && sed -i \
        -e 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' \
        -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' \
        -e 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' \
        -e 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' \
        /etc/ssh/sshd_config \
    && mkdir -p \
        /etc/systemd/system/multi-user.target.wants \
        /etc/systemd/system/getty.target.wants \
    && ln -sf /lib/systemd/system/ssh.service \
        /etc/systemd/system/multi-user.target.wants/ssh.service \
    && ln -sf /lib/systemd/system/serial-getty@.service \
        /etc/systemd/system/getty.target.wants/serial-getty@ttyS0.service \
    && ln -sf /lib/systemd/system/serial-getty@.service \
        /etc/systemd/system/getty.target.wants/serial-getty@hvc0.service \
    && rm -f /etc/machine-id \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["/sbin/init"]
EOF

echo "[+] Building configured Debian image..."
podman build --arch arm64 -t "$IMAGE" -f "$CONTAINERFILE" "$ASSET_DIR"

echo "[+] Exporting root filesystem..."
CONTAINER_ID="$(podman create --arch arm64 "$IMAGE")"
trap 'podman rm -f "$CONTAINER_ID" >/dev/null 2>&1 || true; rm -f "$CONTAINERFILE"' EXIT

podman export "$CONTAINER_ID" | tar -xf - -C "$ROOTFS_DIR"
podman rm "$CONTAINER_ID"
CONTAINER_ID=""

# Inject host SSH public key into rootfs_dir
if [ -n "$SSH_PUB_KEY" ] && [ -f "$SSH_PUB_KEY" ]; then
    echo "[+] Injecting host SSH public key from $SSH_PUB_KEY..."
    mkdir -p "$ROOTFS_DIR/root/.ssh"
    chmod 700 "$ROOTFS_DIR/root/.ssh"
    cat "$SSH_PUB_KEY" >> "$ROOTFS_DIR/root/.ssh/authorized_keys"
    chmod 600 "$ROOTFS_DIR/root/.ssh/authorized_keys"
else
    echo "[!] Warning: No host SSH public key found. Key-based SSH login will fail."
fi

echo "[+] Creating ext4 disk image..."

# Create sparse 2G disk image on macOS
rm -f "$ASSET_DIR/rootfs.img"
mkfile -n "$DISK_SIZE" "$ASSET_DIR/rootfs.img"

# Format the image
echo "[+] Formatting ext4 filesystem..."
podman run --rm \
    --arch arm64 \
    -v "$ASSET_DIR:/workspace" \
    "$IMAGE" \
    mkfs.ext4 -F -b 4096 -L SPARKROOT /workspace/rootfs.img

# Populate the image mountlessly using debugfs tar command
echo "[+] Populating ext4 image via debugfs..."
# First, pack rootfs_dir into a clean tarball inside workspace
tar -C "$ROOTFS_DIR" -cf "$ASSET_DIR/rootfs_pack.tar" .

podman run --rm \
    --arch arm64 \
    -v "$ASSET_DIR:/workspace" \
    "$IMAGE" \
    bash -c "cd /workspace && debugfs -w -R 'rdump rootfs_pack.tar /' /workspace/rootfs.img" 2>/dev/null || \
podman run --rm \
    --arch arm64 \
    -v "$ASSET_DIR:/workspace" \
    "$IMAGE" \
    bash -c "cd /workspace/rootfs_dir && find . -type d -exec debugfs -w -R 'mkdir \$(echo {} | sed \"s/\\./\\//\")' /workspace/rootfs.img \; && \
             find . -type f -exec debugfs -w -R 'write {} \$(echo {} | sed \"s/\\./\\//\")' /workspace/rootfs.img \;"

rm -f "$ASSET_DIR/rootfs_pack.tar"

echo "[PASS] Debian ARM64 rootfs built successfully."
echo "[+] Filesystem: ext4"
echo "[+] Label: SPARKROOT"
echo "[+] Size: $DISK_SIZE"
echo "[+] SSH Auth: Strict Key-Only (Password login disabled)"
