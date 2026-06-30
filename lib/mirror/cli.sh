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

mirror_requirements() {
  [[ -d "$WL_ROOT" ]] || { echo "FAIL source missing: $WL_ROOT"; return 1; }
  [[ -d "$MIRROR_VOLUME" ]] || { echo "FAIL T7 not mounted: $MIRROR_VOLUME"; return 1; }
  command -v rsync >/dev/null || { echo "FAIL rsync missing"; return 1; }
  mkdir -p "$MIRROR_DEST" "$HISTORY_DIR" "$LOG_DIR" "$MANIFEST_DIR"
}

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
EOF_EXCLUDES
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
    cat "$LATEST"
  else
    echo "Latest Manifest ... WARN none"
  fi
}

mirror_diff() {
  mirror_requirements

  tmp_excludes="$(mktemp)"
  mirror_excludes > "$tmp_excludes"

  rsync -ani --delete \
    --exclude-from="$tmp_excludes" \
    "$WL_ROOT/" "$MIRROR_DEST/" | tee "$LOG_DIR/diff-$(date +%Y%m%d-%H%M%S).log"

  rm -f "$tmp_excludes"
}

mirror_update() {
  mirror_requirements

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

  source_files="$(find "$WL_ROOT" -type f \
    ! -path "$WL_ROOT/.git/*" \
    ! -path "*/node_modules/*" \
    ! -path "*/target/*" \
    ! -path "*/DerivedData/*" | wc -l | tr -d ' ')"

  dest_files="$(find "$MIRROR_DEST" -type f \
    ! -path "$MIRROR_DEST/.git/*" \
    ! -path "*/node_modules/*" \
    ! -path "*/target/*" \
    ! -path "*/DerivedData/*" | wc -l | tr -d ' ')"

  result="PASS"
  [[ "$source_files" == "$dest_files" ]] || result="WARN"

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
  "result": "$result"
}
EOF_JSON

  cp "$manifest" "$LATEST"
  rm -f "$tmp_excludes"

  echo
  echo "Mirror update result: $result"
  echo "Manifest: $manifest"
}

mirror_verify() {
  mirror_requirements

  if [[ ! -f "$LATEST" ]]; then
    echo "FAIL no latest mirror manifest"
    return 1
  fi

  source_files="$(find "$WL_ROOT" -type f \
    ! -path "$WL_ROOT/.git/*" \
    ! -path "*/node_modules/*" \
    ! -path "*/target/*" \
    ! -path "*/DerivedData/*" | wc -l | tr -d ' ')"

  dest_files="$(find "$MIRROR_DEST" -type f \
    ! -path "$MIRROR_DEST/.git/*" \
    ! -path "*/node_modules/*" \
    ! -path "*/target/*" \
    ! -path "*/DerivedData/*" | wc -l | tr -d ' ')"

  echo "Mirror Verify"
  echo "Source files:      $source_files"
  echo "Destination files: $dest_files"

  if [[ "$source_files" == "$dest_files" ]]; then
    echo "RESULT PASS"
  else
    echo "RESULT WARN file counts differ"
    return 2
  fi
}

mirror_restore() {
  mirror_requirements
  echo "Restore is intentionally guarded."
  echo "Preview restore with:"
  echo
  echo "rsync -ani --delete \"$MIRROR_DEST/\" \"$WL_ROOT/\""
  echo
  echo "Run manual restore only after reviewing the diff."
}

mirror_main() {
  cmd="${1:-status}"
  case "$cmd" in
    status) mirror_status ;;
    diff) mirror_diff ;;
    update) mirror_update ;;
    verify) mirror_verify ;;
    restore) mirror_restore ;;
    *)
      echo "Usage: wl mirror {status|diff|update|verify|restore}"
      return 64
      ;;
  esac
}

mirror_main "$@"
