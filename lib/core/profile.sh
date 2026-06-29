#!/usr/bin/env bash

: "${WL_HOME:=$HOME/Wonderland}"
: "${WL_PROFILE:=internal-light}"
: "${WL_PROFILE_DIR:=$WL_HOME/profiles}"

wl_profile_path() {
  echo "$WL_PROFILE_DIR/${WL_PROFILE}.json"
}

wl_profile_status() {
  wl_section "Wonderland Profile"

  local profile_path
  profile_path="$(wl_profile_path)"

  if [[ -f "$profile_path" ]]; then
    wl_pass "profile" "$WL_PROFILE"
    wl_pass "profile file" "$profile_path"
  else
    wl_fail "profile" "missing: $profile_path"
  fi
}
