#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
ACADEMY="$WL_ROOT/academy"

fail=0

check_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
    echo "PASS dir: ${path#$WL_ROOT/}"
  else
    echo "FAIL missing dir: ${path#$WL_ROOT/}" >&2
    fail=1
  fi
}

check_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    echo "PASS file: ${path#$WL_ROOT/}"
  else
    echo "FAIL missing file: ${path#$WL_ROOT/}" >&2
    fail=1
  fi
}

check_dir "$ACADEMY"
check_file "$ACADEMY/README.md"

for d in \
  00-governance \
  01-curriculum \
  02-lessons \
  03-labs \
  04-projects \
  05-reference \
  06-diagrams \
  07-quizzes \
  08-certifications \
  09-progress \
  10-assets \
  11-app \
  12-contributors \
  13-automation \
  14-publications \
  archive
do
  check_dir "$ACADEMY/$d"
done

for d in \
  day-001-030 \
  day-031-060 \
  day-061-090 \
  day-091-120 \
  day-121-150 \
  day-151-180 \
  day-181-210 \
  day-211-240 \
  day-241-270 \
  day-271-300 \
  day-301-330 \
  day-331-365
do
  check_dir "$ACADEMY/02-lessons/$d"
done

check_file "$ACADEMY/00-governance/manifesto/MANIFESTO.md"
check_file "$ACADEMY/01-curriculum/templates/LESSON_TEMPLATE.md"
check_file "$ACADEMY/03-labs/LAB_TEMPLATE.md"
check_file "$ACADEMY/09-progress/tracker/PROGRESS.md"

if [[ "$fail" -eq 0 ]]; then
  echo "RESULT PASS"
else
  echo "RESULT FAIL" >&2
  exit 1
fi
