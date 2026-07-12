#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
REGISTRY="$WL_HOME/config/browser/registry.json"
BACKUP_ROOT="$WL_HOME/vault/08-Operations/backups/browser"
SNAPSHOT_ROOT="$WL_HOME/vault/08-Operations/snapshots/browser"
LOG_ROOT="$WL_HOME/vault/08-Operations/logs/browser"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_ROOT" "$SNAPSHOT_ROOT" "$LOG_ROOT"

pass(){ echo "PASS $*"; }
warn(){ echo "WARN $*" >&2; }
fail(){ echo "FAIL $*" >&2; exit 1; }

json_get() {
  python3 - "$REGISTRY" "$1" <<'PY'
import json, sys
path = sys.argv[2].split(".")
with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)
cur = data
for p in path:
    cur = cur[p]
print(cur)
PY
}

browser_keys() {
  python3 - "$REGISTRY" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)
for k in data["browsers"]:
    print(k)
PY
}

browser_path() {
  json_get "browsers.$1.path"
}

browser_name() {
  json_get "browsers.$1.name"
}

browser_role() {
  json_get "browsers.$1.role"
}

set_registry_path() {
  local key="$1"
  local value="$2"

  python3 - "$REGISTRY" "$key" "$value" <<'PY2'
import json, sys
from pathlib import Path

registry = Path(sys.argv[1])
key = sys.argv[2]
value = sys.argv[3]

data = json.loads(registry.read_text())
data["browsers"][key]["path"] = value
registry.write_text(json.dumps(data, indent=2) + "\n")
PY2
}

browser_exists() {
  [[ -d "$(browser_path "$1")" ]]
}

default_browser() {
  json_get "default"
}

fallback_browser() {
  json_get "fallback"
}

resolve_browser() {
  local requested="${1:-}"
  local key fallback

  if [[ -n "$requested" && "$requested" != "default" ]]; then
    echo "$requested"
    return
  fi

  key="$(default_browser)"
  fallback="$(fallback_browser)"

  if browser_exists "$key"; then
    echo "$key"
  elif browser_exists "$fallback"; then
    echo "$fallback"
  else
    echo "$key"
  fi
}

app_version() {
  local app="$1"
  mdls -raw -name kMDItemVersion "$app" 2>/dev/null | sed 's/(null)//'
}

resolve_safari_path() {
  for candidate in \
    "/Applications/Safari.app" \
    "/System/Applications/Safari.app" \
    "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"; do
    [[ -d "$candidate" ]] && echo "$candidate" && return 0
  done
  return 1
}

status_json() {
  python3 - "$REGISTRY" <<'PY2'
import json
import os
import subprocess
import sys
from pathlib import Path

registry = Path(sys.argv[1])
data = json.loads(registry.read_text())

result = {
    "ok": True,
    "default": data.get("default"),
    "fallback": data.get("fallback"),
    "browsers": {}
}

for key, meta in data.get("browsers", {}).items():
    path = Path(meta["path"])
    exists = path.exists()

    version = None
    if exists:
        try:
            version = subprocess.check_output(
                ["mdls", "-raw", "-name", "kMDItemVersion", str(path)],
                stderr=subprocess.DEVNULL,
                text=True
            ).strip()
            if version == "(null)":
                version = None
        except Exception:
            version = None

    result["browsers"][key] = {
        "name": meta.get("name"),
        "path": str(path),
        "role": meta.get("role"),
        "exists": exists,
        "version": version,
        "webgpu": meta.get("webgpu", False)
    }

deprecated = data.get("deprecated", {})
result["deprecated"] = {}
for key, meta in deprecated.items():
    path = Path(meta["path"])
    result["deprecated"][key] = {
        "path": str(path),
        "exists": path.exists(),
        "reason": meta.get("reason")
    }
    if path.exists():
        result["ok"] = False

default = data.get("default")
if default and not result["browsers"].get(default, {}).get("exists"):
    result["ok"] = False

print(json.dumps(result, indent=2))
PY2
}

status() {
  echo "Wonderland Browser Status"
  echo

  for key in $(browser_keys); do
    local name role path
    name="$(browser_name "$key")"
    role="$(browser_role "$key")"
    path="$(browser_path "$key")"

    if [[ "$key" == "safari" ]]; then
      resolved="$(resolve_safari_path || true)"
      [[ -n "$resolved" ]] && path="$resolved"
    fi

    if [[ -d "$path" ]]; then
      version="$(app_version "$path")"
      if [[ -n "$version" ]]; then
        echo "$name: PASS ($role) version=$version"
      else
        echo "$name: PASS ($role)"
      fi
    else
      echo "$name: MISSING ($role)"
    fi
  done

  echo
  echo "Policy:"
  echo "  default: $(default_browser)"
  echo "  fallback: $(fallback_browser)"
  echo "  firefox: privacy / independent-engine validation"
  echo "  safari: WebKit compatibility only"
}

inventory() {
  local out="$WL_HOME/vault/08-Operations/reports/browser-inventory-$STAMP.md"
  mkdir -p "$(dirname "$out")"

  {
    echo "# Wonderland Browser Inventory"
    echo
    echo "Date: $STAMP"
    echo
    echo "## Status"
    status
    echo
    echo "## JSON"
    status_json
  } > "$out"

  pass "browser inventory written: $out"
}

env_check() {
  echo "Wonderland Browser Environment"
  echo

  command -v python3 >/dev/null 2>&1 && pass "python3 available" || fail "python3 missing"
  command -v open >/dev/null 2>&1 && pass "macOS open available" || warn "open command missing"
  command -v mdls >/dev/null 2>&1 && pass "mdls available" || warn "mdls missing"
  command -v spctl >/dev/null 2>&1 && pass "spctl available" || warn "spctl missing"
  command -v codesign >/dev/null 2>&1 && pass "codesign available" || warn "codesign missing"

  [[ -f "$REGISTRY" ]] && pass "registry present: $REGISTRY" || fail "registry missing: $REGISTRY"
  [[ -d "$WL_HOME/config/browser" ]] && pass "config dir present" || warn "config dir missing"
  [[ -d "$BACKUP_ROOT" ]] && pass "backup dir present" || warn "backup dir missing"
  [[ -d "$SNAPSHOT_ROOT" ]] && pass "snapshot dir present" || warn "snapshot dir missing"
}

verify() {
  local ok=1

  env_check || ok=0
  doctor || ok=0
  status_json > "$LOG_ROOT/status-$STAMP.json" || ok=0

  if [[ "$ok" == "1" ]]; then
    echo "RESULT PASS"
  else
    echo "RESULT FAIL"
    return 1
  fi
}

doctor() {
  status
  echo

  local ok=1
  local default fallback deprecated_path

  default="$(default_browser)"
  fallback="$(fallback_browser)"

  if browser_exists "$default"; then
    pass "default browser available: $default"
  else
    warn "default browser missing: $default"
    ok=0
  fi

  if browser_exists "$fallback"; then
    pass "fallback browser available: $fallback"
  else
    warn "fallback browser missing: $fallback"
  fi

  deprecated_path="$(json_get deprecated.chromium.path)"
  if [[ -d "$deprecated_path" ]]; then
    warn "deprecated Chromium detected: $deprecated_path"
    ok=0
  else
    pass "deprecated Chromium absent"
  fi

  for key in $(browser_keys); do
    local path
    path="$(browser_path "$key")"
    [[ -d "$path" ]] || continue

    if spctl --assess --type execute "$path" >/dev/null 2>&1; then
      pass "$key Gatekeeper assessment"
    else
      warn "$key Gatekeeper assessment failed or unavailable"
    fi

    if codesign --verify "$path" >/dev/null 2>&1; then
      pass "$key code signature"
    else
      warn "$key code signature verification inconclusive"
    fi
  done

  if [[ "$ok" == "1" ]]; then
    pass "browser doctor"
  else
    fail "browser doctor found issues"
  fi
}

open_browser() {
  local key url path name
  key="$(resolve_browser "${1:-default}")"
  url="${2:-}"
  path="$(browser_path "$key")"
  name="$(browser_name "$key")"

  [[ -d "$path" ]] || fail "$name not found: $path"

  if [[ -n "$url" ]]; then
    open -a "$path" "$url"
  else
    open -a "$path"
  fi

  pass "opened $name"
}

sync_safari() {
  local resolved
  resolved="$(resolve_safari_path || true)"

  if [[ -n "$resolved" ]]; then
    set_registry_path safari "$resolved"
    pass "Safari path synced: $resolved"
  else
    warn "Safari not found"
    return 1
  fi
}

write_policy() {
  mkdir -p "$WL_HOME/config/browser"

  cat > "$WL_HOME/config/browser/policy.json" <<JSON
{
  "wonderland_browser_policy": {
    "default": "brave",
    "fallback": "chrome",
    "validation_browser": "firefox",
    "webkit_validation": "safari",
    "webgpu_primary": "brave",
    "deprecated": ["homebrew-chromium"],
    "managed_at": "$STAMP"
  }
}
JSON

  pass "wrote $WL_HOME/config/browser/policy.json"
}

reset_firefox() {
  local firefox_root backup
  firefox_root="$HOME/Library/Application Support/Firefox"
  backup="$BACKUP_ROOT/firefox-reset-$STAMP"

  mkdir -p "$backup"

  pkill -f Firefox || true
  sleep 1

  if [[ -d "$firefox_root" ]]; then
    find "$firefox_root" \( -name user.js -o -name compatibility.ini -o -name parent.lock -o -name lock -o -name .parentlock \) -print0 |
      while IFS= read -r -d '' f; do
        rel="${f#$firefox_root/}"
        mkdir -p "$backup/$(dirname "$rel")"
        cp -a "$f" "$backup/$rel" 2>/dev/null || true
        rm -f "$f"
        pass "removed Firefox override/lock: $rel"
      done
  fi

  rm -f "$WL_HOME/config/firefox/profiles/research/user.js" 2>/dev/null || true

  pass "Firefox experimental overrides removed"
  pass "backup: $backup"
}

backup() {
  local dest
  dest="$BACKUP_ROOT/browser-backup-$STAMP"
  mkdir -p "$dest"

  cp -a "$REGISTRY" "$dest/registry.json" 2>/dev/null || true
  cp -a "$WL_HOME/config/browser" "$dest/config-browser" 2>/dev/null || true

  for src in \
    "$HOME/Library/Application Support/BraveSoftware/Brave-Browser" \
    "$HOME/Library/Application Support/Google/Chrome" \
    "$HOME/Library/Application Support/Firefox"; do
    if [[ -d "$src" ]]; then
      name="$(basename "$src" | tr ' /' '__')"
      ditto "$src" "$dest/$name" 2>/dev/null || cp -a "$src" "$dest/$name" 2>/dev/null || true
      pass "backed up $(basename "$src")"
    fi
  done

  pass "browser backup: $dest"
}

snapshot() {
  local dest
  dest="$SNAPSHOT_ROOT/browser-snapshot-$STAMP"
  mkdir -p "$dest"

  {
    echo "# Wonderland Browser Snapshot"
    echo
    echo "Date: $STAMP"
    echo
    ./bin/wl-browser status || true
    echo
    echo "## Applications"
    for key in $(browser_keys); do
      path="$(browser_path "$key")"
      echo "- $key: $path"
      [[ -d "$path" ]] && mdls -name kMDItemVersion "$path" 2>/dev/null || true
    done
  } > "$dest/summary.md"

  cp -a "$REGISTRY" "$dest/registry.json" 2>/dev/null || true
  cp -a "$WL_HOME/config/browser/policy.json" "$dest/policy.json" 2>/dev/null || true

  pass "browser snapshot: $dest"
}

restore() {
  local src="${1:-}"
  [[ -n "$src" ]] || fail "restore requires backup path"
  [[ -d "$src" ]] || fail "backup path not found: $src"

  if [[ -f "$src/registry.json" ]]; then
    cp "$src/registry.json" "$REGISTRY"
    pass "restored registry"
  fi

  if [[ -d "$src/config-browser" ]]; then
    rm -rf "$WL_HOME/config/browser"
    cp -a "$src/config-browser" "$WL_HOME/config/browser"
    pass "restored browser config"
  fi

  pass "restore complete"
}

update_browsers() {
  snapshot

  if command -v brew >/dev/null 2>&1; then
    brew update
    brew upgrade --cask brave-browser google-chrome firefox 2>&1 | tee "$LOG_ROOT/update-$STAMP.log" || true
    pass "brew cask update attempted"
  else
    warn "Homebrew missing; skipped browser updates"
  fi

  doctor
}

profiles() {
  mkdir -p "$WL_HOME/config/browser/profiles"

  cat > "$WL_HOME/config/browser/profiles/profiles.json" <<'JSON'
{
  "brave": {
    "Wonderland": {
      "role": "daily",
      "notes": "Default Wonderland-OS browser profile"
    }
  },
  "chrome": {
    "Wonderland Dev": {
      "role": "development",
      "notes": "Compatibility and developer testing"
    }
  },
  "firefox": {
    "Wonderland Operations": {
      "role": "operations",
      "notes": "Managed operations profile"
    },
    "Wonderland Research": {
      "role": "research",
      "notes": "Independent-engine research profile"
    },
    "Wonderland Sandbox": {
      "role": "sandbox",
      "notes": "Hardened sandbox profile"
    }
  },
  "safari": {
    "Default": {
      "role": "webkit-validation",
      "notes": "System WebKit validation"
    }
  }
}
JSON

  pass "wrote $WL_HOME/config/browser/profiles/profiles.json"
}

cert_index() {
  local cert_dir="$WL_HOME/vault/08-Operations/certifications/browser"
  local index="$cert_dir/index.md"

  mkdir -p "$cert_dir"

  {
    echo "# Wonderland Browser Certification Index"
    echo
    echo "Updated: $STAMP"
    echo
    find "$cert_dir" -maxdepth 1 -type f -name 'browser-certified-*.md' | sort -r | while read -r f; do
      echo "- $(basename "$f")"
    done
  } > "$index"

  pass "browser certification index written: $index"
}

certify() {
  local cert_dir="$WL_HOME/vault/08-Operations/certifications/browser"
  local cert_file="$cert_dir/browser-certified-$STAMP.md"

  mkdir -p "$cert_dir"

  {
    echo "# Wonderland Browser Certification"
    echo
    echo "Date: $STAMP"
    echo
    echo "## Status"
    status || true
    echo
    echo "## Doctor"
    doctor || true
    echo
    echo "## Policy"
    cat "$WL_HOME/config/browser/policy.json" 2>/dev/null || true
    echo
    echo "## Registry"
    cat "$WL_HOME/config/browser/registry.json" 2>/dev/null || true
  } > "$cert_file"

  pass "browser certification written: $cert_file"
  cert_index
}

handoff() {
  local out="$WL_HOME/vault/08-Operations/handoffs/browser-architecture-$STAMP.md"
  mkdir -p "$(dirname "$out")"

  {
    echo "# Wonderland Browser Architecture Handoff"
    echo
    echo "Date: $STAMP"
    echo
    echo "## Standard"
    echo
    echo "- Brave: default daily browser and WebGPU primary"
    echo "- Google Chrome: fallback and development compatibility"
    echo "- Firefox: privacy and independent-engine validation"
    echo "- Safari: WebKit validation"
    echo "- Homebrew Chromium: deprecated and explicitly rejected"
    echo
    echo "## Commands"
    echo
    echo '```bash'
    echo './bin/wl-browser status'
    echo './bin/wl-browser doctor'
    echo './bin/wl-browser verify'
    echo './bin/wl-browser backup'
    echo './bin/wl-browser snapshot'
    echo './bin/wl-browser certify'
    echo './bin/wl browser doctor'
    echo '```'
    echo
    echo "## Current Status"
    status
    echo
    echo "## Registry"
    cat "$WL_HOME/config/browser/registry.json" 2>/dev/null || true
    echo
    echo "## Policy"
    cat "$WL_HOME/config/browser/policy.json" 2>/dev/null || true
  } > "$out"

  pass "browser handoff written: $out"
}

benchmark() {
  local url="${1:-https://browserbench.org/Speedometer3.0/}"
  open_browser default "$url"
  pass "benchmark opened: $url"
}

case "${1:-status}" in
  status) status ;;
  status-json) status_json ;;
  doctor) doctor ;;
  verify) verify ;;
  inventory) inventory ;;
  env) env_check ;;
  open)
    shift
    if [[ "${1:-}" == "brave" || "${1:-}" == "chrome" || "${1:-}" == "firefox" || "${1:-}" == "safari" || "${1:-}" == "default" ]]; then
      key="${1:-default}"
      shift || true
      open_browser "$key" "${1:-}"
    else
      open_browser default "${1:-}"
    fi
    ;;
  policy) write_policy ;;
  sync-safari) sync_safari ;;
  reset-firefox) reset_firefox ;;
  backup) backup ;;
  snapshot) snapshot ;;
  restore) shift; restore "${1:-}" ;;
  update) update_browsers ;;
  profiles) profiles ;;
  benchmark) shift || true; benchmark "${1:-}" ;;
  handoff) handoff ;;
  certify) certify ;;
  bootstrap)
    write_policy
    profiles
    reset_firefox
    doctor
    snapshot
    ;;
  *)
    cat <<USAGE
Usage:
  wl-browser status
  wl-browser status-json
  wl-browser env
  wl-browser doctor
  wl-browser verify
  wl-browser inventory
  wl-browser open [browser] [url]
  wl-browser policy
  wl-browser sync-safari
  wl-browser profiles
  wl-browser reset-firefox
  wl-browser backup
  wl-browser restore <backup-path>
  wl-browser snapshot
  wl-browser update
  wl-browser benchmark [url]
  wl-browser certify
  wl-browser handoff
  wl-browser bootstrap
USAGE
    exit 1
    ;;
esac
