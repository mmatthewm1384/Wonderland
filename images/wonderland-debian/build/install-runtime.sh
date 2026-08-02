#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ROOTFS="$ROOT/work/rootfs"

echo "Installing Wonderland runtime"

chroot "$ROOTFS" apt-get update

xargs -a "$ROOT/config/packages.txt" \
chroot "$ROOTFS" apt-get install -y

echo "Runtime packages installed"
