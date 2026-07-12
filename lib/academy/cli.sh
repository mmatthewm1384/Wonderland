#!/usr/bin/env bash
set -euo pipefail

source "$WL_ROOT/lib/academy/common.sh"

wl_academy_help() {
  cat <<'HELP'
Wonderland Academy

Usage:
  wl academy <command>

Commands:
  today
  lesson
  lab
  quiz
  journal
  inventory
  report
  review
  registry generate|validate|list
  manifest generate|validate|summary
  build [build|validate|summary]
  quality
  verify
  certify
  chapter create
  chapter verify
  chapter certify
  chapter build
  chapter package
  chapter publish
HELP
}

wl_academy_main() {
  local cmd="${1:-help}"
  shift || true

  case "$cmd" in
    help|-h|--help)
      wl_academy_help
      ;;

    today|lesson|lab|quiz|journal)
      echo "PASS academy $cmd command registered"
      ;;

    inventory)
      "$WL_ROOT/lib/academy/registry.py" list
      ;;

    report|review)
      echo "Wonderland Academy report"
      echo "Root: $(academy_root)"
      if [[ -f "$(academy_root)/registry/chapters.json" ]]; then
        "$WL_ROOT/lib/academy/registry.py" validate
      else
        echo "WARN registry missing"
        echo "Chapters: $(academy_find_chapters | wc -l | tr -d ' ')"
      fi
      ;;




    build)
      local sub="${1:-build}"
      shift || true
      case "$sub" in
        build|validate|summary)
          "$WL_ROOT/lib/academy/build.py" "$sub" "$@"
          ;;
        *)
          echo "FAIL unknown academy build command: $sub" >&2
          exit 64
          ;;
      esac
      ;;

    manifest)
      local sub="${1:-summary}"
      shift || true
      case "$sub" in
        generate|validate|summary)
          "$WL_ROOT/lib/academy/manifest.py" "$sub" "$@"
          ;;
        *)
          echo "FAIL unknown academy manifest command: $sub" >&2
          exit 64
          ;;
      esac
      ;;

    registry)
      local sub="${1:-list}"
      shift || true
      case "$sub" in
        generate|validate|list)
          "$WL_ROOT/lib/academy/registry.py" "$sub" "$@"
          ;;
        *)
          echo "FAIL unknown academy registry command: $sub" >&2
          exit 64
          ;;
      esac
      ;;

    quality)
      source "$WL_ROOT/lib/academy/quality.sh"
      academy_quality "$@"
      ;;

    verify)
      source "$WL_ROOT/lib/academy/verify.sh"
      academy_verify "$@"
      ;;

    certify)
      source "$WL_ROOT/lib/academy/certify.sh"
      academy_certify "$@"
      ;;

    chapter)
      local sub="${1:-help}"
      shift || true
      case "$sub" in
        verify)
          source "$WL_ROOT/lib/academy/verify.sh"
          academy_verify "$@"
          ;;
        certify)
          source "$WL_ROOT/lib/academy/certify.sh"
          academy_certify "$@"
          ;;
        build)
          "$WL_ROOT/lib/academy/build.py" build "$@"
          ;;
        create|package|publish)
          echo "PASS academy chapter $sub command registered"
          ;;
        *)
          echo "FAIL unknown academy chapter command: $sub" >&2
          exit 64
          ;;
      esac
      ;;

    *)
      echo "FAIL unknown academy command: $cmd" >&2
      wl_academy_help
      exit 64
      ;;
  esac
}
