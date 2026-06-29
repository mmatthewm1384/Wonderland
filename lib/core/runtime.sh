#!/usr/bin/env bash

: "${WL_HOME:=$HOME/Wonderland}"
: "${WL_RUNTIME_INSTANCE:=wonderland-rootless}"

wl_runtime_exists() {
  limactl list 2>/dev/null | awk '{print $1}' | grep -qx "$WL_RUNTIME_INSTANCE"
}

wl_runtime_running() {
  limactl list 2>/dev/null | grep -q "^${WL_RUNTIME_INSTANCE}[[:space:]]\+Running"
}

wl_runtime_start() {
  limactl start "$WL_RUNTIME_INSTANCE" >/dev/null 2>&1 || true
}

wl_runtime_stop() {
  limactl stop "$WL_RUNTIME_INSTANCE" >/dev/null 2>&1 || true
}
