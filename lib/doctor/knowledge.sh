#!/usr/bin/env bash
set -euo pipefail

wl_doctor_knowledge() {
  local root fail score missing
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  fail=0
  missing=0
  score=100

  echo "Knowledge Doctor"
  echo

  for f in \
    knowledge/README.md \
    knowledge/foundation/WL-KNOW-001-Foundation.md \
    knowledge/decisions/ADR-0001-rootless-by-default.md \
    knowledge/bootstrap/bootstrap.txt \
    knowledge/manifest.json \
    knowledge/generated/index.md \
    knowledge/generated/commands.md \
    knowledge/generated/applications.md \
    knowledge/generated/documentation.md \
    knowledge/generated/services.md \
    knowledge/generated/statistics.md \
    knowledge/generated/repository-inventory.md \
    knowledge/generated/knowledge-graph.md
  do
    if [ -f "$root/$f" ]; then
      echo "PASS $f"
    else
      echo "FAIL missing $f"
      fail=1
      missing=$((missing + 1))
    fi
  done

  score=$((100 - missing * 7))
  [ "$score" -lt 0 ] && score=0

  echo
  echo "Knowledge Score .... $score"

  if [ "$fail" -eq 0 ]; then
    echo "RESULT PASS"
  else
    echo "RESULT FAIL"
    return 1
  fi
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  wl_doctor_knowledge "$@"
fi
