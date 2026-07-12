#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "$WL_ROOT/lib/mirror/common.sh"

usage(){
  cat <<'EOF'
Usage:
  wl mirror status
  wl mirror doctor
  wl mirror manifest
  wl mirror diff
  wl mirror update
  wl mirror verify
  wl mirror certify
  wl mirror restore --dry-run [target]
  wl mirror clean-stale --dry-run
EOF
}

mirror_status(){
  mirror_dirs
  echo "Wonderland Mirror Status"
  echo
  printf 'Source:      %s\n' "$WL_MIRROR_SOURCE"
  printf 'Volume:      %s\n' "$WL_MIRROR_VOLUME"
  printf 'Destination: %s\n' "$WL_MIRROR_DEST"
  echo
  mirror_mounted && pass "T7 mounted" || fail "T7 not mounted"
  mirror_writable && pass "T7 writable" || warn "T7 not writable"
  [ -d "$WL_MIRROR_DEST" ] && pass "mirror destination exists" || warn "mirror destination missing"
  [ -f "$WL_MIRROR_MANIFEST" ] && pass "manifest exists" || warn "manifest missing"
  [ -f "$WL_MIRROR_MANIFEST" ] && { echo; cat "$WL_MIRROR_MANIFEST"; }
}

mirror_doctor(){
  local failed=0
  mirror_dirs
  echo "Wonderland Mirror Doctor"
  echo
  command -v rsync >/dev/null && pass "rsync available" || { fail "rsync missing"; failed=1; }
  command -v python3 >/dev/null && pass "python3 available" || { fail "python3 missing"; failed=1; }
  [ -d "$WL_ROOT/bin" ] && pass "Wonderland root valid" || { fail "Wonderland root invalid"; failed=1; }
  mirror_mounted && pass "T7 mounted" || { fail "T7 not mounted: $WL_MIRROR_VOLUME"; failed=1; }
  mirror_writable && pass "T7 writable" || { fail "T7 not writable"; failed=1; }
  [ -f "$WL_MIRROR_MANIFEST" ] && python3 -m json.tool "$WL_MIRROR_MANIFEST" >/dev/null && pass "manifest valid json" || warn "manifest missing or not yet initialized"
  echo
  if [ "$failed" -eq 0 ]; then
    mirror_manifest_write PASS doctor
    echo "RESULT PASS"
  else
    mirror_manifest_write FAIL doctor
    echo "RESULT FAIL"
    return 1
  fi
}

mirror_manifest(){
  mirror_manifest_write UNKNOWN manifest
  cat "$WL_MIRROR_MANIFEST"
}

mirror_diff(){
  mirror_mounted || { fail "T7 not mounted"; return 1; }
  mirror_dirs
  mkdir -p "$WL_MIRROR_DEST"
  local log excludes
  log="$WL_MIRROR_LOG_DIR/diff-$(mirror_stamp).log"
  excludes="$(mirror_excludes_file)"
  rsync --archive --human-readable --itemize-changes --dry-run --exclude-from="$excludes" "$WL_MIRROR_SOURCE/" "$WL_MIRROR_DEST/" | tee "$log"
  echo
  echo "Diff log: $log"
  echo "RESULT PASS"
}

mirror_update(){
  mirror_mounted || { fail "T7 not mounted"; return 1; }
  mirror_writable || { fail "T7 not writable"; return 1; }
  mirror_dirs
  mkdir -p "$WL_MIRROR_DEST"
  local log excludes
  log="$WL_MIRROR_LOG_DIR/update-$(mirror_stamp).log"
  excludes="$(mirror_excludes_file)"
  echo "Updating Wonderland mirror..."
  echo "Source: $WL_MIRROR_SOURCE"
  echo "Dest:   $WL_MIRROR_DEST"
  echo
  rsync --archive --human-readable --itemize-changes --safe-links --exclude-from="$excludes" "$WL_MIRROR_SOURCE/" "$WL_MIRROR_DEST/" | tee "$log"
  mirror_manifest_write PASS update
  cp "$WL_MIRROR_MANIFEST" "$WL_MIRROR_HISTORY_DIR/manifest-update-$(mirror_stamp).json"
  echo
  echo "Update log: $log"
  echo "RESULT PASS"
}

mirror_verify(){
  mirror_mounted || { fail "T7 not mounted"; return 1; }
  [ -d "$WL_MIRROR_DEST" ] || { fail "mirror destination missing"; return 1; }
  mirror_dirs
  local log tmp excludes
  log="$WL_MIRROR_LOG_DIR/verify-$(mirror_stamp).log"
  tmp="$WL_MIRROR_STATE_DIR/verify-current.txt"
  excludes="$(mirror_excludes_file)"
  rsync --archive --checksum --dry-run --itemize-changes --exclude-from="$excludes" "$WL_MIRROR_SOURCE/" "$WL_MIRROR_DEST/" | tee "$log" > "$tmp"
  if [ -s "$tmp" ]; then
    warn "mirror drift detected"
    echo "Verify log: $log"
    mirror_manifest_write WARN verify
    echo "RESULT WARN"
    return 2
  fi
  pass "mirror matches source"
  echo "Verify log: $log"
  mirror_manifest_write PASS verify
  echo "RESULT PASS"
}

mirror_restore(){
  local mode="${1:-}"
  local target="${2:-/tmp/wonderland-restore-preview}"
  [ "$mode" = "--dry-run" ] || { fail "restore requires --dry-run for safety"; return 1; }
  mirror_mounted || { fail "T7 not mounted"; return 1; }
  [ -d "$WL_MIRROR_DEST" ] || { fail "mirror destination missing"; return 1; }
  mkdir -p "$target"
  local log="$WL_MIRROR_LOG_DIR/restore-dry-run-$(mirror_stamp).log"
  rsync --archive --dry-run --itemize-changes "$WL_MIRROR_DEST/" "$target/" | tee "$log"
  echo
  echo "Restore dry-run target: $target"
  echo "Restore dry-run log: $log"
  echo "RESULT PASS"
}

mirror_clean_stale(){
  [ "${1:-}" = "--dry-run" ] || { fail "clean-stale requires --dry-run for safety"; return 1; }
  mirror_diff
}

mirror_certify(){
  local failed=0
  local cert="$WL_ROOT/vault/08-Operations/certifications/mirror-certified-$(mirror_stamp).json"
  mirror_doctor || failed=1
  mirror_diff >/dev/null || failed=1
  mirror_update || failed=1
  mirror_verify || failed=1
  local status=PASS
  [ "$failed" -eq 0 ] || status=FAIL
  python3 - "$cert" "$status" "$WL_MIRROR_SOURCE" "$WL_MIRROR_DEST" "$(mirror_now)" <<'PYCERT'
import json, os, sys
path, status, source, dest, ts = sys.argv[1:]
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w", encoding="utf-8") as f:
    json.dump({
        "certification": "wonderland-mirror",
        "engine": "Wonderland Mirror Engine 2.0",
        "version": 2,
        "status": status,
        "source": source,
        "destination": dest,
        "certified_at": ts,
        "safety": {
            "destructive_delete_default": False,
            "restore_default": "dry-run",
            "clean_stale_default": "dry-run-required"
        }
    }, f, indent=2, sort_keys=True)
    f.write("\n")
PYCERT
  mirror_manifest_write "$status" certify
  echo
  echo "Certification: $cert"
  echo "RESULT $status"
  [ "$status" = PASS ]
}

cmd="${1:-help}"
shift || true

case "$cmd" in
  status) mirror_status "$@" ;;
  doctor) mirror_doctor "$@" ;;
  manifest) mirror_manifest "$@" ;;
  diff) mirror_diff "$@" ;;
  update) mirror_update "$@" ;;
  verify) mirror_verify "$@" ;;
  certify) mirror_certify "$@" ;;
  restore) mirror_restore "$@" ;;
  clean-stale) mirror_clean_stale "$@" ;;
  help|-h|--help) usage ;;
  *) echo "FAIL unknown mirror command: $cmd"; usage; exit 64 ;;
esac
