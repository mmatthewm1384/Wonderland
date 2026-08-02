#!/usr/bin/env bash
set -euo pipefail

ROOTFS=/workspace/artifacts/rootfs

mkdir -p "$ROOTFS"

debootstrap \
 --arch arm64 \
 stable \
 "$ROOTFS" \
 http://deb.debian.org/debian

echo "Debian rootfs created:"
du -sh "$ROOTFS"
