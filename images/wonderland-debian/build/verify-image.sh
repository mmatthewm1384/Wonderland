#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."

ROOTFS="$ROOT/work/rootfs"

echo "Verifying image"

test -d "$ROOTFS/etc"
test -d "$ROOTFS/home"

echo "PASS: filesystem"
