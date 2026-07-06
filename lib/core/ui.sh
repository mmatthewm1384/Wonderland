#!/usr/bin/env bash
set -euo pipefail

WL_BG="#05070A"
WL_CYAN="\033[38;2;0;229;255m"
WL_PURPLE="\033[38;2;112;0;255m"
WL_GREEN="\033[38;2;0;255;102m"
WL_YELLOW="\033[38;2;255;212;71m"
WL_RED="\033[38;2;255;51;102m"
WL_DIM="\033[2m"
WL_RESET="\033[0m"
WL_BOLD="\033[1m"

wl_logo() {
  printf "${WL_PURPLE}╭────────────────────────────────────╮${WL_RESET}\n"
  printf "${WL_PURPLE}│${WL_RESET} ${WL_CYAN}${WL_BOLD}Wonderland Runtime${WL_RESET} ${WL_DIM}local-first OS layer${WL_RESET} ${WL_PURPLE}│${WL_RESET}\n"
  printf "${WL_PURPLE}╰────────────────────────────────────╯${WL_RESET}\n"
}

wl_ok() {
  printf "${WL_GREEN}PASS${WL_RESET} %s\n" "$*"
}

wl_warn() {
  printf "${WL_YELLOW}WARN${WL_RESET} %s\n" "$*"
}

wl_fail() {
  printf "${WL_RED}FAIL${WL_RESET} %s\n" "$*"
}

wl_info() {
  printf "${WL_CYAN}INFO${WL_RESET} %s\n" "$*"
}

wl_palette() {
  cat <<PALETTE
Wonderland Palette

background  #05070A
cyan        #00E5FF
purple      #7000FF
green       #00FF66
yellow      #FFD447
red         #FF3366
PALETTE
}

wl_spinner() {
  local message="${1:-Working}"
  local pid="$2"
  local frames=("◐" "◓" "◑" "◒")
  local colors=("$WL_CYAN" "$WL_PURPLE" "$WL_GREEN" "$WL_PURPLE")
  local i=0

  while kill -0 "$pid" 2>/dev/null; do
    local frame="${frames[$((i % ${#frames[@]}))]}"
    local color="${colors[$((i % ${#colors[@]}))]}"
    printf "\r${color}%s${WL_RESET} %s" "$frame" "$message"
    i=$((i + 1))
    sleep 0.12
  done

  wait "$pid"
  local code=$?

  if [[ "$code" -eq 0 ]]; then
    printf "\r${WL_GREEN}●${WL_RESET} %s\n" "$message"
  else
    printf "\r${WL_RED}●${WL_RESET} %s\n" "$message"
  fi

  return "$code"
}

wl_run_with_spinner() {
  local message="$1"
  shift

  local safe
  safe="$(printf '%s' "$message" | tr ' /:' '___')"
  local log="${WL_LOG_DIR:-/tmp}/wl-${safe}.log"

  (
    "$@"
  ) >"$log" 2>&1 &

  if wl_spinner "$message" "$!"; then
    return 0
  fi

  wl_fail "$message"
  wl_warn "log: $log"
  tail -40 "$log" || true
  return 1
}

