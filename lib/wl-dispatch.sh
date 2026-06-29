#!/usr/bin/env bash

wl_dispatch() {
  local cmd="${1:-help}"
  shift || true

  case "$cmd" in
    doctor)
      exec "$WL_HOME/bin/wl-doctor" "$@"
      ;;

    start)
      exec "$WL_HOME/bin/wl-start" "$@"
      ;;

    boot)
      exec "$WL_HOME/bin/wl-boot" "$@"
      ;;

    report|lifecycle-report)
      exec "$WL_HOME/bin/wl-lifecycle-report" "$@"
      ;;

    universe)
      exec "$WL_HOME/bin/wl-universe" "$@"
      ;;

    storage)
      exec "$WL_HOME/bin/wl-storage" "$@"
      ;;

    governance)
      exec "$WL_HOME/bin/wl-governance" "$@"
      ;;

    services)
      exec "$WL_HOME/bin/wl-services" "$@"
      ;;

    runtime)
      exec "$WL_HOME/bin/wl-runtime" "$@"
      ;;

    profile)
      exec "$WL_HOME/bin/wl-profile" "$@"
      ;;

    capability|capabilities)
      exec "$WL_HOME/bin/wl-capability" "$@"
      ;;

    api)
      exec "$WL_HOME/bin/wl-api" "$@"
      ;;

    context)
      exec "$WL_HOME/bin/wl-context" "$@"
      ;;

    state)
      exec "$WL_HOME/bin/wl-state" "$@"
      ;;

    status)
      exec "$WL_HOME/bin/wl-status" "$@"
      ;;

    env)
      wl_bootstrap_info
      ;;

    test)
      exec "$WL_HOME/bin/wl-test" "$@"
      ;;

    lint)
      exec "$WL_HOME/bin/wl-lint" "$@"
      ;;

    verify)
      exec "$WL_HOME/bin/wl-verify" "$@"
      ;;

    certify)
      exec "$WL_HOME/bin/wl-certify" "$@"
      ;;

    release)
      exec "$WL_HOME/bin/wl-release" "$@"
      ;;

    release-validate)
      exec "$WL_HOME/bin/wl-release-validate" "$@"
      ;;

    baseline)
      exec "$WL_HOME/bin/wl-baseline" "$@"
      ;;

    handoff)
      exec "$WL_HOME/bin/wl-handoff" "$@"
      ;;

    checkpoint)
      exec "$WL_HOME/bin/wl-checkpoint" "$@"
      ;;

    docs)
      exec "$WL_HOME/bin/wl-docs" "$@"
      ;;

    help|-h|--help)
      cat <<HELP
Wonderland CLI

Usage:
  wl start
  wl doctor
  wl universe status
  wl lifecycle-report start
  wl storage ...
  wl governance ...
  wl services ...
  wl status
HELP
      ;;

    *)
      echo "FAIL unknown command: $cmd"
      echo "RESULT FAIL"
      return 1
      ;;
  esac
}
