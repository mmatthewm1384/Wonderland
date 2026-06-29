#!/usr/bin/env bash

wl_command_registry_file() {
  mkdir -p "$WL_ROOT/config/commands"
  printf '%s\n' "$WL_ROOT/config/commands/registry.json"
}

wl_command_phase_for() {
  local name="$1"

  case "$name" in
    wl-boot|wl-start|wl-stop) printf 'lifecycle' ;;
    wl-verify*|wl-doctor*|wl-test|wl-lint|wl-core-22-doctor) printf 'validation' ;;
    wl-release*|wl-baseline|wl-checkpoint|wl-handoff|wl-certify) printf 'release' ;;
    wl-services*|wl-service-*|wl-nats|wl-dns|wl-vaultwarden) printf 'services' ;;
    wl-storage*) printf 'storage' ;;
    wl-runtime*|wl-state|wl-status|wl-health*) printf 'runtime' ;;
    wl-chaos*) printf 'chaos' ;;
    wl-matrix*|wl-theomatrix|wl-the-matrix|wl-spin-city|wl-agitate) printf 'matrix' ;;
    wl-vault*) printf 'vault' ;;
    wl-rootless*|wl-vm) printf 'infrastructure' ;;
    wl-firefox*|wl-wallpaper*|wl-control-center*) printf 'apps' ;;
    *) printf 'utility' ;;
  esac
}
