#!/usr/bin/env bash

wl_release_history_append() {
  local action="$1"
  local manifest="${2:-}"
  local file
  file="$(wl_release_history_file)"
  mkdir -p "$(dirname "$file")"

  jq -c -n \
    --arg at "$(wl_timestamp)" \
    --arg action "$action" \
    --arg manifest "$manifest" \
    --arg git_commit "$(git rev-parse --short HEAD 2>/dev/null || printf unknown)" \
    '{at:$at,action:$action,manifest:$manifest,git_commit:$git_commit}' >> "$file"
}

wl_release_history() {
  local file
  file="$(wl_release_history_file)"

  [ -f "$file" ] || {
    wl_warn "no release history"
    wl_result PASS
    return 0
  }

  tail -20 "$file"
  wl_result PASS
}

wl_release_repair_history() {
  local file bad
  file="$(wl_release_history_file)"
  bad="${file}.bad"

  mkdir -p "$(dirname "$file")"
  touch "$file"

  python3 - "$file" "$bad" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
bad = Path(sys.argv[2])

good = []
bad_lines = []

for idx, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
    if not line.strip():
        continue
    try:
        json.loads(line)
        good.append(line)
    except json.JSONDecodeError:
        bad_lines.append(f"{idx}: {line}")

path.write_text("\n".join(good) + ("\n" if good else ""), encoding="utf-8")

if bad_lines:
    bad.write_text("\n".join(bad_lines) + "\n", encoding="utf-8")
    print(f"WARN quarantined {len(bad_lines)} bad release history line(s) to {bad}")
else:
    print("PASS release history already valid")
PY

  wl_release_validate_history
  wl_result PASS
}

wl_release_validate_history() {
  local file
  file="$(wl_release_history_file)"

  [ -f "$file" ] || {
    wl_warn "release history not present yet: $file"
    return 0
  }

  local err
  err="$(
    python3 - "$file" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])

for idx, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
    if not line.strip():
        continue

    try:
        obj = json.loads(line)
    except json.JSONDecodeError as exc:
        print(f"{path}:{idx}: invalid JSON: {exc.msg}")
        raise SystemExit(1)

    for key in ("at", "action", "manifest", "git_commit"):
        if key not in obj:
            print(f"{path}:{idx}: missing key: {key}")
            raise SystemExit(1)

    if obj["action"] not in {"build", "promote", "rollback"}:
        print(f"{path}:{idx}: invalid action: {obj['action']}")
        raise SystemExit(1)
PY
  )" || {
    wl_fail "release history invalid: $err"
    wl_result FAIL
    return "$WL_ERR_RELEASE"
  }

  wl_pass "release history valid"
}
