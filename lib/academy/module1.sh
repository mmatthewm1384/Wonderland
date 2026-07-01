#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
ACADEMY="$WL_ROOT/academy"

fail=0

check_count() {
  local label="$1"
  local path="$2"
  local pattern="$3"
  local min="$4"
  local count

  count="$(find "$path" -type f -name "$pattern" | wc -l | tr -d ' ')"

  if [[ "$count" -ge "$min" ]]; then
    echo "PASS $label: $count"
  else
    echo "FAIL $label: $count / $min" >&2
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

check_contains() {
  local path="$1"
  local text="$2"

  if grep -q "$text" "$path"; then
    echo "PASS content: ${path#$WL_ROOT/} contains '$text'"
  else
    echo "FAIL content: ${path#$WL_ROOT/} missing '$text'" >&2
    fail=1
  fi
}

echo "Wonderland Academy — Module 1 Certification"
echo
echo "Running content lint..."
if wl academy lint >/tmp/wl-academy-module1-lint.out 2>/tmp/wl-academy-module1-lint.err; then
  echo "PASS content lint"
else
  echo "FAIL content lint" >&2
  cat /tmp/wl-academy-module1-lint.err >&2 || true
  fail=1
fi
echo

check_count "Module 1 lessons" "$ACADEMY/02-lessons/day-001-030" "day-*.md" 30
check_count "Module 1 labs" "$ACADEMY/03-labs/foundations" "lab-*.md" 30
check_count "Daily quizzes" "$ACADEMY/07-quizzes/daily" "quiz-*.md" 30

check_file "$ACADEMY/01-curriculum/year-1/module-01-foundations/README.md"
check_file "$ACADEMY/05-reference/glossary/FOUNDATIONS.md"
check_file "$ACADEMY/05-reference/cheat-sheets/FOUNDATIONS.md"
check_file "$ACADEMY/06-diagrams/computer-science/FOUNDATIONS.md"

for n in $(seq 1 30); do
  day="$(printf '%03d' "$n")"
  lesson="$(find "$ACADEMY/02-lessons/day-001-030" -type f -name "day-$day-*.md" | head -1)"
  lab="$(find "$ACADEMY/03-labs/foundations" -type f -name "lab-$day-*.md" | head -1)"
  quiz="$(find "$ACADEMY/07-quizzes/daily" -type f -name "quiz-$day-*.md" | head -1)"

  if [[ -z "$lesson" ]]; then
    echo "FAIL missing lesson day $day" >&2
    fail=1
    continue
  fi

  if [[ -z "$lab" ]]; then
    echo "FAIL missing lab day $day" >&2
    fail=1
  fi

  if [[ -z "$quiz" ]]; then
    echo "FAIL missing quiz day $day" >&2
    fail=1
  fi

  check_contains "$lesson" "## Learning Objectives"
  check_contains "$lesson" "## Wonderland Integration"
  check_contains "$lesson" "## Verification Checklist"
done

if [[ "$fail" -eq 0 ]]; then
  echo "RESULT PASS"
else
  echo "RESULT FAIL" >&2
  exit 1
fi
