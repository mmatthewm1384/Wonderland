#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
ACADEMY="$WL_ROOT/academy"

count() {
  find "$1" -type f -name "$2" 2>/dev/null | wc -l | tr -d ' '
}

echo "Wonderland Academy Summary"
echo "──────────────────────────"
echo
echo "Root ................. $WL_ROOT"
echo "Academy .............. $ACADEMY"
echo
echo "Core Documents"
echo "  Constitution ....... $([[ -f "$ACADEMY/CONSTITUTION.md" ]] && echo PASS || echo FAIL)"
echo "  Canon .............. $([[ -f "$ACADEMY/CANON.md" ]] && echo PASS || echo FAIL)"
echo "  Codex .............. $([[ -f "$ACADEMY/CODEX.md" ]] && echo PASS || echo FAIL)"
echo
echo "Content"
echo "  Lessons ............ $(count "$ACADEMY/02-lessons" 'day-*.md')"
echo "  Labs ............... $(count "$ACADEMY/03-labs" 'lab-*.md')"
echo "  Quizzes ............ $(count "$ACADEMY/07-quizzes" 'quiz-*.md')"
echo "  Journals ........... $(count "$ACADEMY/09-progress/journal" 'day-*.md')"
echo
echo "Current Progress"
wl academy status
echo
echo "Recommended Gates"
echo "  wl academy lint"
echo "  wl academy module1"
echo "  wl academy quality"
