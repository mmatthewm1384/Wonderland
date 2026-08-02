#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."

ROOTFS="$ROOT/work/rootfs"

echo "Applying Wonderland hardening"

chroot "$ROOTFS" useradd \
  --uid 501 \
  --create-home \
  --shell /bin/bash \
  wonderland

echo "Hardening complete"
