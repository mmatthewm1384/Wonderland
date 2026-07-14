#!/usr/bin/env bash
set -euo pipefail

ram_secret_mount() {
  local size_mb="${1:-64}"
  local label="${2:-WL_RAM_SECRETS}"
  local sectors=$((size_mb * 2048))
  local disk mount

  disk="$(hdiutil attach -nomount "ram://${sectors}" | awk '{print $1; exit}')"
  diskutil eraseVolume APFS "$label" "$disk" >/dev/null
  mount="/Volumes/$label"

  printf '%s\n' "$disk|$mount"
}

ram_secret_cleanup() {
  local disk="${1:-}"
  local mount="${2:-}"

  sync 2>/dev/null || true
  [ -n "$mount" ] && diskutil unmount force "$mount" >/dev/null 2>&1 || true
  [ -n "$disk" ] && hdiutil detach "$disk" -force >/dev/null 2>&1 || true
}

ram_secret_orphans() {
  hdiutil info | grep -A3 -B3 'WL_RAM_SECRETS' || true
}
