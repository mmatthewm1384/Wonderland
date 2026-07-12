#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
PROFILE_NAME="${2:-research}"
MODE="${1:-safe}"

FIREFOX_BIN="/Applications/Firefox.app/Contents/MacOS/firefox"
FIREFOX_ROOT="$HOME/Library/Application Support/Firefox"
PROFILES_INI="$FIREFOX_ROOT/profiles.ini"
BACKUP_DIR="$WL_HOME/vault/08-Operations/backups/firefox-webgpu"
STAMP="$(date +%Y%m%d-%H%M%S)"

die(){ echo "FAIL $*" >&2; exit 1; }
pass(){ echo "PASS $*"; }

[[ -x "$FIREFOX_BIN" ]] || die "Firefox not found: $FIREFOX_BIN"
mkdir -p "$FIREFOX_ROOT" "$BACKUP_DIR"

create_profile_if_missing() {
  if ! grep -q "Name=$PROFILE_NAME" "$PROFILES_INI" 2>/dev/null; then
    "$FIREFOX_BIN" -CreateProfile "$PROFILE_NAME" >/dev/null
    pass "created Firefox profile: $PROFILE_NAME"
  fi
}

profile_dir() {
  awk -v wanted="$PROFILE_NAME" '
    BEGIN { name=""; path=""; rel="1"; found=0 }
    /^\[/ {
      if (name == wanted && path != "") {
        print rel "|" path
        found=1
        exit
      }
      name=""; path=""; rel="1"
      next
    }
    /^Name=/ { name=substr($0,6) }
    /^Path=/ { path=substr($0,6) }
    /^IsRelative=/ { rel=substr($0,12) }
    END {
      if (!found && name == wanted && path != "") print rel "|" path
    }
  ' "$PROFILES_INI"
}

resolve_profile_dir() {
  create_profile_if_missing
  [[ -f "$PROFILES_INI" ]] || die "profiles.ini missing"

  local rec rel path
  rec="$(profile_dir)"
  [[ -n "$rec" ]] || die "could not resolve profile: $PROFILE_NAME"

  rel="${rec%%|*}"
  path="${rec#*|}"

  if [[ "$rel" == "1" ]]; then
    echo "$FIREFOX_ROOT/$path"
  else
    echo "$path"
  fi
}

write_safe() {
  local dir userjs
  dir="$(resolve_profile_dir)"
  userjs="$dir/user.js"

  [[ -f "$userjs" ]] && cp "$userjs" "$BACKUP_DIR/${PROFILE_NAME}-user.js.$STAMP.bak"

  cat > "$userjs" <<'JS'
// Wonderland Firefox Research Profile — WebGPU safe mode.
// Managed by wl-firefox-webgpu.
//
// Safe mode avoids aggressive force flags that can cause stuck loading.

user_pref("dom.webgpu.enabled", true);

user_pref("webgl.disabled", false);
user_pref("layers.acceleration.disabled", false);
user_pref("media.hardware-video-decoding.enabled", true);
JS

  mkdir -p "$WL_HOME/config/firefox/profiles/$PROFILE_NAME"
  cp "$userjs" "$WL_HOME/config/firefox/profiles/$PROFILE_NAME/user.js"

  pass "safe WebGPU prefs applied"
  pass "$userjs"
}

write_force() {
  local dir userjs
  dir="$(resolve_profile_dir)"
  userjs="$dir/user.js"

  [[ -f "$userjs" ]] && cp "$userjs" "$BACKUP_DIR/${PROFILE_NAME}-user.js.$STAMP.bak"

  cat > "$userjs" <<'JS'
// Wonderland Firefox Research Profile — WebGPU force mode.
// Managed by wl-firefox-webgpu.
//
// Use only if safe mode does not expose WebGPU.

user_pref("dom.webgpu.enabled", true);
user_pref("gfx.webgpu.force-enabled", true);
user_pref("gfx.webgpu.ignore-blocklist", true);

user_pref("webgl.disabled", false);
user_pref("webgl.force-enabled", true);

user_pref("layers.acceleration.disabled", false);
user_pref("media.hardware-video-decoding.enabled", true);
JS

  mkdir -p "$WL_HOME/config/firefox/profiles/$PROFILE_NAME"
  cp "$userjs" "$WL_HOME/config/firefox/profiles/$PROFILE_NAME/user.js"

  pass "force WebGPU prefs applied"
  pass "$userjs"
}

repair() {
  local dir
  dir="$(resolve_profile_dir)"

  pkill -f Firefox || true
  sleep 2

  rm -f "$dir"/{parent.lock,lock,.parentlock,compatibility.ini}

  if [[ -f "$dir/user.js" ]]; then
    cp "$dir/user.js" "$BACKUP_DIR/${PROFILE_NAME}-user.js.repair.$STAMP.bak"
    mv "$dir/user.js" "$dir/user.js.disabled.$STAMP"
    pass "disabled user.js"
  fi

  pass "profile repaired: $dir"
}

write_compat() {
  local dir userjs
  dir="$(resolve_profile_dir)"
  userjs="$dir/user.js"

  [[ -f "$userjs" ]] && cp "$userjs" "$BACKUP_DIR/${PROFILE_NAME}-user.js.$STAMP.bak"

  cat > "$userjs" <<'JS'
// Wonderland Firefox Research Profile — GPU compatibility mode.
// Managed by wl-firefox-webgpu.
//
// Use when Firefox logs GLD_TEXTURE_INDEX_2D / unloadable texture errors.
// This disables aggressive WebGPU/WebGL forcing while preserving normal pages.

user_pref("dom.webgpu.enabled", false);
user_pref("gfx.webgpu.force-enabled", false);
user_pref("gfx.webgpu.ignore-blocklist", false);

user_pref("webgl.disabled", false);
user_pref("webgl.force-enabled", false);

user_pref("layers.acceleration.disabled", false);
user_pref("gfx.webrender.all", false);
user_pref("media.hardware-video-decoding.enabled", true);
JS

  mkdir -p "$WL_HOME/config/firefox/profiles/$PROFILE_NAME"
  cp "$userjs" "$WL_HOME/config/firefox/profiles/$PROFILE_NAME/user.js"

  pass "GPU compatibility prefs applied"
  pass "$userjs"
}


write_software() {
  local dir userjs
  dir="$(resolve_profile_dir)"
  userjs="$dir/user.js"

  [[ -f "$userjs" ]] && cp "$userjs" "$BACKUP_DIR/${PROFILE_NAME}-user.js.$STAMP.bak"

  cat > "$userjs" <<'JS'
// Wonderland Firefox Research Profile — software graphics fallback.
// Managed by wl-firefox-webgpu.
//
// Use when macOS logs GLD_TEXTURE_INDEX_2D / unloadable texture errors.

user_pref("dom.webgpu.enabled", false);
user_pref("gfx.webgpu.force-enabled", false);
user_pref("gfx.webgpu.ignore-blocklist", false);

user_pref("webgl.disabled", true);
user_pref("webgl.force-enabled", false);

user_pref("layers.acceleration.disabled", true);
user_pref("gfx.webrender.all", false);
user_pref("gfx.webrender.software", true);

user_pref("media.hardware-video-decoding.enabled", false);
JS

  mkdir -p "$WL_HOME/config/firefox/profiles/$PROFILE_NAME"
  cp "$userjs" "$WL_HOME/config/firefox/profiles/$PROFILE_NAME/user.js"

  pass "software graphics fallback applied"
  pass "$userjs"
}


launch() {
  pkill -f Firefox || true
  sleep 2
  "$FIREFOX_BIN" -P "$PROFILE_NAME" --no-remote
}

case "$MODE" in
  safe) write_safe ;;
  force) write_force ;;
  compat) write_compat ;;
  software) write_software ;;
  repair) repair ;;
  launch) launch ;;
  *)
    cat <<USAGE
Usage:
  wl-firefox-webgpu safe [profile]
  wl-firefox-webgpu force [profile]
  wl-firefox-webgpu compat [profile]
  wl-firefox-webgpu software [profile]
  wl-firefox-webgpu repair [profile]
  wl-firefox-webgpu launch [profile]
USAGE
    exit 1
    ;;
esac
