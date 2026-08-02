#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

WORK="$ROOT/work"
ROOTFS="$WORK/rootfs"

mkdir -p "$ROOTFS"

echo "Creating Debian root filesystem"

debootstrap \
  --arch=arm64 \
  stable \
  "$ROOTFS" \
  http://deb.debian.org/debian

tar -czf \
  "$WORK/rootfs.tar.gz" \
  -C "$ROOTFS" .

echo "Bootstrap complete"
