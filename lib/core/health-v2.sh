#!/usr/bin/env bash

# Wonderland Core Health v2
# Canonical health API. Legacy wl_pass/wl_warn/wl_fail remain supported.

wl_health_reset() {
  wl_passes=0
  wl_warnings=0
  wl_failures=0
  wl_corruptions=0
}

wl_health_pass() {
  wl_pass "$@"
}

wl_health_warn() {
  wl_warn "$@"
}

wl_health_fail() {
  wl_fail "$@"
}

wl_health_corrupt() {
  wl_corrupt "$@"
}

wl_health_result() {
  wl_result
}

wl_health_exit() {
  wl_exit
}
