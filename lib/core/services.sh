#!/usr/bin/env bash

: "${WL_HOME:=$HOME/Wonderland}"
: "${WL_SERVICES_CONFIG:=$WL_HOME/config/services.env}"
: "${WL_RUNTIME_INSTANCE:=wonderland-rootless}"

if [[ -f "$WL_SERVICES_CONFIG" ]]; then
  # shellcheck disable=SC1090
  source "$WL_SERVICES_CONFIG"
else
  WL_REQUIRED_SERVICES="wl-loki"
  WL_OPTIONAL_SERVICES="wl-vaultwarden wl-vaultwarden-db"
  WL_ROOTLESS_SERVICES="$WL_REQUIRED_SERVICES $WL_OPTIONAL_SERVICES"
fi

wl_service_running() {
  local svc="$1"
  LIMA_INSTANCE="$WL_RUNTIME_INSTANCE" nerdctl ps --format '{{.Names}}' 2>/dev/null | grep -qx "$svc"
}

wl_service_exists() {
  local svc="$1"
  LIMA_INSTANCE="$WL_RUNTIME_INSTANCE" nerdctl ps -a --format '{{.Names}}' 2>/dev/null | grep -qx "$svc"
}

wl_service_create() {
  local svc="$1"

  case "$svc" in
    wl-loki)
      LIMA_INSTANCE="$WL_RUNTIME_INSTANCE" nerdctl run -d \
        --name wl-loki \
        --restart unless-stopped \
        -p 3100:3100 \
        grafana/loki:2.9.8 \
        -config.file=/etc/loki/local-config.yaml \
        >/dev/null
      ;;
    *)
      return 0
      ;;
  esac
}

wl_service_start() {
  local svc="$1"

  if ! wl_service_exists "$svc"; then
    wl_service_create "$svc" || return 1
  fi

  LIMA_INSTANCE="$WL_RUNTIME_INSTANCE" nerdctl start "$svc" >/dev/null 2>&1 || true
}

wl_services_start_required() {
  local svc
  for svc in $WL_REQUIRED_SERVICES; do
    wl_service_start "$svc"
    if wl_service_running "$svc"; then
      wl_pass "$svc" "up"
    else
      wl_fail "$svc" "not up"
    fi
  done
}

wl_services_start_optional() {
  local svc
  for svc in $WL_OPTIONAL_SERVICES; do
    wl_service_start "$svc"
    if wl_service_running "$svc"; then
      wl_pass "$svc" "up"
    else
      wl_warn "$svc" "not up"
    fi
  done
}

wl_services_start_all() {
  wl_services_start_required
  wl_services_start_optional
}
