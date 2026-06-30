#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
MIRROR_VOLUME="${MIRROR_VOLUME:-/Volumes/T7_Wonderland}"
MIRROR_DEST="${MIRROR_DEST:-$MIRROR_VOLUME/Wonderland}"

STATE_DIR="$WL_ROOT/vault/08-Operations/replication"
HISTORY_DIR="$STATE_DIR/history"
LOG_DIR="$STATE_DIR/logs"
MANIFEST_DIR="$STATE_DIR/manifests"
LATEST="$MANIFEST_DIR/latest.json"
LATEST_DIFF="$MANIFEST_DIR/latest.diff"

mkdir -p "$HISTORY_DIR" "$LOG_DIR" "$MANIFEST_DIR"

mirror_excludes() {
  cat <<'EOF_EXCLUDES'
.git/
.DS_Store
node_modules/
target/
DerivedData/
.swiftpm/
build/
dist/
.cache/
tmp/
persistence/
EOF_EXCLUDES
}

mirror_requirements() {
  [[ -d "$WL_ROOT" ]] || { echo "FAIL source missing: $WL_ROOT"; return 1; }
  [[ -d "$MIRROR_VOLUME" ]] || { echo "FAIL T7 not mounted: $MIRROR_VOLUME"; return 1; }
  command -v rsync >/dev/null || { echo "FAIL rsync missing"; return 1; }
  mkdir -p "$MIRROR_DEST" "$HISTORY_DIR" "$LOG_DIR" "$MANIFEST_DIR"
}

mirror_attach() {
  if [[ -x "$WL_ROOT/lib/storage/cli.sh" ]]; then
    "$WL_ROOT/lib/storage/cli.sh" attach || true
  fi

  if [[ -d "$MIRROR_VOLUME" ]]; then
    echo "T7 Mounted ........ PASS"
    return 0
  fi

  echo "FAIL T7 not mounted: $MIRROR_VOLUME"
  echo "Attach the T7 drive, then rerun the command."
  return 1
}

mirror_eject() {
  if [[ -x "$WL_ROOT/lib/storage/cli.sh" ]]; then
    "$WL_ROOT/lib/storage/cli.sh" eject || true
  fi

  if [[ -d "$MIRROR_VOLUME" ]]; then
    diskutil eject "$MIRROR_VOLUME"
  else
    echo "T7 already unmounted"
  fi
}

mirror_inventory() {
  local root="$1"

  find "$root" \
    \( -path "$root/.git" \
    -o -path "*/node_modules" \
    -o -path "*/target" \
    -o -path "*/DerivedData" \
    -o -path "*/.swiftpm" \
    -o -path "*/build" \
    -o -path "*/dist" \
    -o -path "*/.cache" \
    -o -path "*/tmp" \
    -o -path "*/persistence" \) -prune \
    -o -type f -print | sort
}

mirror_status() {
  echo "Wonderland Mirror Status"
  echo
  echo "Source:      $WL_ROOT"
  echo "Destination: $MIRROR_DEST"
  echo

  [[ -d "$WL_ROOT" ]] && echo "Source ............ PASS" || echo "Source ............ FAIL"
  [[ -d "$MIRROR_VOLUME" ]] && echo "T7 Mounted ........ PASS" || echo "T7 Mounted ........ FAIL"
  [[ -d "$MIRROR_DEST" ]] && echo "Mirror Exists ..... PASS" || echo "Mirror Exists ..... WARN"

  if [[ -f "$LATEST" ]]; then
    echo "Latest Manifest ... PASS"
    echo
    cat "$LATEST"
  else
    echo "Latest Manifest ... WARN none"
  fi
}

mirror_diff() {
  mirror_attach
  mirror_requirements

  local id log tmp_excludes
  id="$(date +%Y%m%d-%H%M%S)"
  log="$LOG_DIR/diff-$id.log"
  tmp_excludes="$(mktemp)"
  mirror_excludes > "$tmp_excludes"

  rsync -ani --delete \
    --exclude-from="$tmp_excludes" \
    "$WL_ROOT/" "$MIRROR_DEST/" | tee "$log"

  rm -f "$tmp_excludes"
  echo
  echo "Diff log: $log"
}

mirror_update() {
  mirror_attach
  mirror_requirements

  local id log manifest tmp_excludes start_epoch end_epoch duration commit
  local source_files dest_files result

  id="$(date +%Y%m%d-%H%M%S)"
  log="$LOG_DIR/update-$id.log"
  manifest="$HISTORY_DIR/$id.json"
  tmp_excludes="$(mktemp)"
  mirror_excludes > "$tmp_excludes"

  start_epoch="$(date +%s)"
  commit="$(git -C "$WL_ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"

  echo "Updating Wonderland T7 mirror..."
  echo "Source: $WL_ROOT"
  echo "Dest:   $MIRROR_DEST"
  echo

  rsync -aHAX --delete \
    --exclude-from="$tmp_excludes" \
    --info=stats2,progress2 \
    "$WL_ROOT/" "$MIRROR_DEST/" | tee "$log"

  end_epoch="$(date +%s)"
  duration="$((end_epoch - start_epoch))"

  rm -f "$tmp_excludes"

  if mirror_verify >/tmp/wl-mirror-verify.out 2>&1; then
    result="PASS"
  else
    result="WARN"
  fi

  source_files="$(mirror_inventory "$WL_ROOT" | wc -l | tr -d ' ')"
  dest_files="$(mirror_inventory "$MIRROR_DEST" | wc -l | tr -d ' ')"

  cat > "$manifest" <<EOF_JSON
{
  "id": "$id",
  "intent": "wonderland.replication.t7_hot_mirror",
  "source": "$WL_ROOT",
  "destination": "$MIRROR_DEST",
  "git_commit": "$commit",
  "source_files": $source_files,
  "destination_files": $dest_files,
  "duration_seconds": $duration,
  "log": "$log",
  "diff": "$LATEST_DIFF",
  "result": "$result"
}
EOF_JSON

  cp "$manifest" "$LATEST"

  cat /tmp/wl-mirror-verify.out
  rm -f /tmp/wl-mirror-verify.out

  echo
  echo "Mirror update result: $result"
  echo "Manifest: $manifest"
}

mirror_verify() {
  mirror_requirements

  local src_list dst_list
  src_list="$(mktemp)"
  dst_list="$(mktemp)"

  mirror_inventory "$WL_ROOT" \
    | sed "s#^$WL_ROOT/##" > "$src_list"

  mirror_inventory "$MIRROR_DEST" \
    | sed "s#^$MIRROR_DEST/##" > "$dst_list"

  echo "Mirror Verify"
  echo "Source files:      $(wc -l < "$src_list" | tr -d ' ')"
  echo "Destination files: $(wc -l < "$dst_list" | tr -d ' ')"

  if diff -u "$src_list" "$dst_list" > "$LATEST_DIFF"; then
    rm -f "$src_list" "$dst_list"
    echo "RESULT PASS"
  else
    rm -f "$src_list" "$dst_list"
    echo "RESULT WARN inventory differs"
    echo "Diff: $LATEST_DIFF"
    return 2
  fi
}

mirror_clean_stale() {
  mirror_requirements

  local stale_roots=(
    "$MIRROR_DEST/persistence"
  )

  echo "Mirror Clean Stale"
  echo

  for path in "${stale_roots[@]}"; do
    if [[ -e "$path" ]]; then
      echo "STALE root found: $path"
      du -sh "$path" || true
      echo "Removing: $path"
      rm -rf "$path"
    else
      echo "OK not present: $path"
    fi
  done

  echo
  echo "Running verify after stale cleanup..."
  mirror_verify || true

  echo
  echo "If verify still warns, inspect:"
  echo "$LATEST_DIFF"
}

mirror_restore() {
  mirror_requirements

  echo "Restore is intentionally guarded."
  echo
  echo "Preview restore with:"
  echo "rsync -ani --delete \"$MIRROR_DEST/\" \"$WL_ROOT/\""
  echo
  echo "Manual restore only after reviewing the diff."
}

mirror_main() {
  local cmd="${1:-status}"
  case "$cmd" in
    attach) mirror_attach ;;
    eject) mirror_eject ;;
    status) mirror_status ;;
    diff) mirror_diff ;;
    update) mirror_update ;;
    verify) mirror_verify ;;
    clean-stale) mirror_clean_stale ;;
    restore) mirror_restore ;;
    *)
      echo "Usage: wl mirror {attach|eject|status|diff|update|verify|clean-stale|restore}"
      return 64
      ;;
  esac
}

mirror_main "$@"
