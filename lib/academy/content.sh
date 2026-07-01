#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
ACADEMY="$WL_ROOT/academy"

required_sections=(
  "## Lesson Overview"
  "## Learning Objectives"
  "## Prerequisites"
  "## Why This Matters"
  "## Core Concepts"
  "## Technical Deep Dive"
  "## Real-World Example"
  "## Hands-On Lab"
  "## Wonderland Integration"
  "## Verification Checklist"
  "## Knowledge Check"
  "## Optional Challenge"
  "## Summary"
  "## Further Reading"
  "## Next Lesson Preview"
)

lesson_files_module1() {
  find "$ACADEMY/02-lessons/day-001-030" -type f -name 'day-*.md' | sort
}

cmd_lint() {
  local fail=0
  local checked=0

  echo "Wonderland Academy Content Lint"
  echo

  while IFS= read -r file; do
    checked=$((checked + 1))

    for section in "${required_sections[@]}"; do
      if ! grep -qF "$section" "$file"; then
        echo "FAIL ${file#$WL_ROOT/}: missing $section" >&2
        fail=1
      fi
    done
  done < <(lesson_files_module1)

  echo
  echo "Checked lessons: $checked"

  if [[ "$fail" -eq 0 ]]; then
    echo "RESULT PASS"
  else
    echo "RESULT FAIL" >&2
    exit 1
  fi
}

cmd_migrate_module1() {
  python3 - "$ACADEMY" <<'PY'
from pathlib import Path
import re
import sys

academy = Path(sys.argv[1])
lesson_dir = academy / "02-lessons/day-001-030"

required = [
    ("Lesson Overview", "This lesson introduces the topic and explains how it connects to Wonderland."),
    ("Learning Objectives", "- Explain the topic from first principles.\n- Identify where it appears in Wonderland.\n- Complete the lab and verify the result."),
    ("Prerequisites", "- Access to `~/Wonderland`\n- Basic terminal access"),
    ("Why This Matters", "Reliable engineering depends on accurate mental models. This concept helps explain how Wonderland behaves under real operating conditions."),
    ("Core Concepts", "- State\n- Representation\n- Abstraction\n- Verification"),
    ("Technical Deep Dive", "Start with the machine-level behavior, then connect it to the human-facing abstraction used by engineers."),
    ("Real-World Example", "`wl doctor` converts low-level system facts into understandable PASS/FAIL output."),
    ("Hands-On Lab", "See the matching lab file under `academy/03-labs/foundations/`."),
    ("Wonderland Integration", "Identify one place in Wonderland where this concept appears and document it in your journal."),
    ("Verification Checklist", "- [ ] I can explain the concept.\n- [ ] I completed the lab.\n- [ ] I connected the concept to Wonderland.\n- [ ] I recorded notes in my journal."),
    ("Knowledge Check", "See the matching quiz file under `academy/07-quizzes/daily/`."),
    ("Optional Challenge", "Find one additional Wonderland subsystem that uses this concept indirectly."),
    ("Summary", "This lesson strengthens the foundation needed to debug, design, operate, and improve Wonderland."),
    ("Further Reading", "- `academy/05-reference/glossary/FOUNDATIONS.md`\n- `academy/05-reference/cheat-sheets/FOUNDATIONS.md`"),
    ("Next Lesson Preview", "The next lesson builds on this concept and connects it to the next layer of the computing stack."),
]

updated = 0

for path in sorted(lesson_dir.glob("day-*.md")):
    text = path.read_text()
    original = text

    if not text.startswith("# "):
        title = path.stem.replace("-", " ").title()
        text = f"# {title}\n\n{text}"

    # Normalize common old headings.
    text = text.replace("## Objectives", "## Learning Objectives")
    text = text.replace("## Lab\n", "## Hands-On Lab\n")
    text = text.replace("## Verification\n", "## Verification Checklist\n")
    text = text.replace("## Quiz\n", "## Knowledge Check\n")

    existing_sections = set(re.findall(r"^## (.+)$", text, flags=re.MULTILINE))

    append = []
    for name, body in required:
        if name not in existing_sections:
            append.append(f"\n## {name}\n{body}\n")

    if append:
        text = text.rstrip() + "\n" + "".join(append)

    if text != original:
        path.write_text(text)
        updated += 1

print(f"PASS migrated Module 1 lessons; updated: {updated}")
PY
}

cmd_author() {
  local day="${1:-}"
  local current

  if [[ -z "$day" ]]; then
    current="$(python3 - "$ACADEMY/academy.json" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    print(json.load(f).get("current_day", 1))
PY
)"
    day="$(printf "%03d" "$current")"
  else
    day="$(printf "%03d" "$day")"
  fi

  local lesson lab quiz journal
  lesson="$(find "$ACADEMY/02-lessons" -type f -name "day-${day}-*.md" | head -1)"
  lab="$(find "$ACADEMY/03-labs" -type f -name "lab-${day}-*.md" | head -1)"
  quiz="$(find "$ACADEMY/07-quizzes" -type f -name "quiz-${day}-*.md" | head -1)"
  journal="$ACADEMY/09-progress/journal/day-${day}.md"

  mkdir -p "$(dirname "$journal")"
  [[ -f "$journal" ]] || cat > "$journal" <<DOC
# Day ${day} Journal

## What I Learned

## Wonderland Improvement

## Questions

## Next Step
DOC

  echo "Wonderland Academy Author Workspace"
  echo
  echo "Lesson:  ${lesson:-MISSING}"
  echo "Lab:     ${lab:-MISSING}"
  echo "Quiz:    ${quiz:-MISSING}"
  echo "Journal: $journal"
  echo

  if command -v open >/dev/null 2>&1; then
    [[ -n "${lesson:-}" ]] && open "$lesson"
    [[ -n "${lab:-}" ]] && open "$lab"
    [[ -n "${quiz:-}" ]] && open "$quiz"
    open "$journal"
  fi
}

case "${1:-help}" in
  lint)
    cmd_lint
    ;;
  migrate)
    case "${2:-module1}" in
      module1) cmd_migrate_module1 ;;
      *) echo "FAIL supported migration: module1" >&2; exit 1 ;;
    esac
    ;;
  author)
    shift || true
    cmd_author "${1:-}"
    ;;
  *)
    cat <<'HELP'
Usage:
  wl academy lint
  wl academy migrate module1
  wl academy author [day]
HELP
    ;;
esac
