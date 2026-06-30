#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
ACADEMY="$WL_ROOT/academy"
STATE="$ACADEMY/academy.json"

require_state() {
  [[ -f "$STATE" ]] || {
    echo "FAIL academy state missing: $STATE" >&2
    echo "Run: wl academy init" >&2
    exit 1
  }
}

json_get() {
  python3 - "$STATE" "$1" <<'PY'
import json, sys
path, key = sys.argv[1], sys.argv[2]
with open(path) as f:
    data = json.load(f)
value = data.get(key)
print("" if value is None else value)
PY
}

lesson_title_for_day() {
  local day="$1"
  python3 - "$day" <<'PY'
import sys
day = int(sys.argv[1])
topics = {
  1: "Binary Numbers",
  2: "Hexadecimal",
  3: "Bits and Bytes",
  4: "CPU Architecture",
  5: "Memory",
  6: "Files and Bytes",
  7: "Permissions as State",
}
print(topics.get(day, f"Academy Lesson {day:03d}"))
PY
}

path_for_day() {
  local kind="$1"
  local day="$2"

  case "$kind" in
    lesson)
      find "$ACADEMY/02-lessons" -type f -name "day-$(printf '%03d' "$day")-*.md" | sort | head -1
      ;;
    lab)
      find "$ACADEMY/03-labs" -type f -name "lab-$(printf '%03d' "$day")-*.md" | sort | head -1
      ;;
    quiz)
      find "$ACADEMY/07-quizzes" -type f -name "quiz-$(printf '%03d' "$day")-*.md" | sort | head -1
      ;;
  esac
}

journal_path_for_day() {
  local day="$1"
  echo "$ACADEMY/09-progress/journal/day-$(printf '%03d' "$day").md"
}

cmd_status() {
  require_state
  echo "Wonderland Academy"
  echo
  printf "Current Day .......... %s\n" "$(json_get current_day)"
  printf "Total Days ........... %s\n" "$(json_get total_days)"
  printf "Current Module ....... %s\n" "$(json_get current_module)"
  printf "Lessons Completed .... %s\n" "$(json_get lessons_completed)"
  printf "Labs Completed ....... %s\n" "$(json_get labs_completed)"
  printf "Current Streak ....... %s\n" "$(json_get current_streak)"
  printf "Next Lesson .......... %s\n" "$(json_get next_lesson)"
}

cmd_progress() {
  require_state
  local completed total percent
  completed="$(json_get lessons_completed)"
  total="$(json_get total_days)"
  percent=$(( completed * 100 / total ))

  echo "Wonderland Academy Progress"
  echo
  printf "Completed ............ %s / %s\n" "$completed" "$total"
  printf "Progress ............. %s%%\n" "$percent"
}

cmd_today() {
  require_state
  local day lesson lab quiz journal
  day="$(json_get current_day)"
  lesson="$(path_for_day lesson "$day")"
  lab="$(path_for_day lab "$day")"
  quiz="$(path_for_day quiz "$day")"
  journal="$(journal_path_for_day "$day")"

  echo "Wonderland Academy — Today"
  echo
  printf "Day .................. %03d\n" "$day"
  printf "Module ............... %s\n" "$(json_get current_module)"
  printf "Lesson ............... %s\n" "$(lesson_title_for_day "$day")"
  printf "Lesson File .......... %s\n" "${lesson:-MISSING}"
  printf "Lab File ............. %s\n" "${lab:-MISSING}"
  printf "Quiz File ............ %s\n" "${quiz:-MISSING}"
  printf "Journal File ......... %s\n" "$journal"
  echo
  echo "Commands:"
  echo "  wl academy start"
  echo "  wl academy lab"
  echo "  wl academy quiz"
  echo "  wl academy journal"
  echo "  wl academy build"
  echo "  wl academy complete"
}

show_file_for_day() {
  local kind="$1"
  require_state
  local day file
  day="$(json_get current_day)"
  file="$(path_for_day "$kind" "$day")"

  [[ -n "$file" ]] || {
    echo "FAIL $kind file missing for day $day" >&2
    echo "Run: wl academy generate year-1" >&2
    exit 1
  }

  echo "$file"
  echo
  sed -n '1,140p' "$file"
}

cmd_start() {
  require_state
  local day
  day="$(json_get current_day)"
  echo "Starting Wonderland Academy Day $(printf '%03d' "$day")"
  echo
  show_file_for_day lesson
}

cmd_lesson() { show_file_for_day lesson; }
cmd_lab() { show_file_for_day lab; }
cmd_quiz() { show_file_for_day quiz; }

cmd_journal() {
  require_state
  local day journal
  day="$(json_get current_day)"
  journal="$(journal_path_for_day "$day")"

  mkdir -p "$(dirname "$journal")"

  [[ -f "$journal" ]] || cat > "$journal" <<DOC
# Day $(printf '%03d' "$day") Journal

## What I Learned

## Wonderland Improvement

## Questions

## Next Step
DOC

  echo "$journal"
}

cmd_build() {
  require_state
  local day topic
  day="$(json_get current_day)"
  topic="$(lesson_title_for_day "$day")"

  echo "Wonderland Build Prompt"
  echo
  printf "Day .................. %03d\n" "$day"
  printf "Topic ................ %s\n" "$topic"
  echo
  echo "Recommended build work:"
  case "$day" in
    1)
      echo "- Add a short binary/bytes note to Academy reference."
      echo "- Inspect one Wonderland config or log file with xxd."
      echo "- Document where flags, exit codes, or PASS/FAIL states appear in Wonderland."
      ;;
    2)
      echo "- Inspect a Wonderland file with xxd and compare binary vs hex output."
      echo "- Add a hex reference note under academy/05-reference/cheat-sheets."
      ;;
    3)
      echo "- Document bits, bytes, KiB, MiB, and GiB in the glossary."
      echo "- Compare byte sizes of several Wonderland scripts."
      ;;
    *)
      echo "- Identify one Wonderland subsystem related to today's topic."
      echo "- Add or improve one small test, doctor check, or documentation note."
      echo "- Verify with wl doctor all or the relevant module doctor."
      ;;
  esac
}

cmd_generate() {
  require_state
  local scope="${1:-year-1}"

  [[ "$scope" == "year-1" ]] || {
    echo "FAIL supported scope: year-1" >&2
    exit 1
  }

  python3 - "$ACADEMY" <<'PY'
from pathlib import Path
import re, sys

academy = Path(sys.argv[1])

topics = {
    1: "Binary Numbers",
    2: "Hexadecimal",
    3: "Bits and Bytes",
    4: "CPU Architecture",
    5: "Memory",
    6: "Files and Bytes",
    7: "Permissions as State",
}

def bucket(day: int) -> str:
    ranges = [
        (1,30),(31,60),(61,90),(91,120),(121,150),(151,180),
        (181,210),(211,240),(241,270),(271,300),(301,330),(331,365)
    ]
    for a,b in ranges:
        if a <= day <= b:
            return f"day-{a:03d}-{b:03d}"
    raise ValueError(day)

def slug(s: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")

created = 0
for day in range(1, 366):
    topic = topics.get(day, f"Academy Lesson {day:03d}")
    lesson_dir = academy / "02-lessons" / bucket(day)
    lab_dir = academy / "03-labs" / "generated"
    quiz_dir = academy / "07-quizzes" / "daily"

    lesson_dir.mkdir(parents=True, exist_ok=True)
    lab_dir.mkdir(parents=True, exist_ok=True)
    quiz_dir.mkdir(parents=True, exist_ok=True)

    lesson = lesson_dir / f"day-{day:03d}-{slug(topic)}.md"
    lab = lab_dir / f"lab-{day:03d}-{slug(topic)}.md"
    quiz = quiz_dir / f"quiz-{day:03d}-{slug(topic)}.md"

    if not lesson.exists():
        lesson.write_text(f"""# Day {day:03d} — {topic}

## Objectives

## Core Concepts

## Deep Dive

## Lab

See: `academy/03-labs/generated/{lab.name}`

## Wonderland Integration

## Verification

## Quiz

See: `academy/07-quizzes/daily/{quiz.name}`

## Reflection
""")
        created += 1

    if not lab.exists():
        lab.write_text(f"""# Lab {day:03d} — {topic}

## Objective

## Prerequisites

## Steps

## Verification

## Rollback

## Wonderland Improvement

## Reflection
""")
        created += 1

    if not quiz.exists():
        quiz.write_text(f"""# Quiz {day:03d} — {topic}

1.
2.
3.
4.
5.
""")
        created += 1

print(f"PASS generated year-1 scaffolding; files created: {created}")
PY
}

cmd_complete() {
  require_state
  local day journal
  day="$(json_get current_day)"
  journal="$(journal_path_for_day "$day")"

  mkdir -p "$(dirname "$journal")"

  [[ -f "$journal" ]] || cat > "$journal" <<DOC
# Day $(printf '%03d' "$day") Journal

## What I Learned

## Wonderland Improvement

## Questions

## Next Step
DOC

  python3 - "$STATE" <<'PY'
import json, sys

path = sys.argv[1]
topics = {
  1: "Binary Numbers",
  2: "Hexadecimal",
  3: "Bits and Bytes",
  4: "CPU Architecture",
  5: "Memory",
  6: "Files and Bytes",
  7: "Permissions as State",
}

def module_for_day(day):
    if day <= 30: return "Foundations"
    if day <= 60: return "Linux & Operating Systems"
    if day <= 90: return "Networking"
    if day <= 120: return "Programming & Software Engineering"
    if day <= 150: return "Databases & Data"
    if day <= 180: return "DevOps & Infrastructure"
    if day <= 210: return "Security & Cryptography"
    if day <= 240: return "AI & Machine Learning"
    if day <= 270: return "Distributed Systems"
    if day <= 300: return "Desktop & Mobile Development"
    if day <= 330: return "Platform Architecture"
    return "Capstone"

with open(path) as f:
    data = json.load(f)

current = int(data.get("current_day", 1))
next_day = current + 1

data["lessons_completed"] = int(data.get("lessons_completed", 0)) + 1
data["current_day"] = next_day
data["current_streak"] = int(data.get("current_streak", 0)) + 1
data["current_module"] = module_for_day(next_day)
data["next_lesson"] = topics.get(next_day, f"Academy Lesson {next_day:03d}")

with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

  echo "PASS completed Day $(printf '%03d' "$day")"
  echo "Journal: $journal"
}

cmd_review() {
  require_state
  cmd_status
  echo
  echo "Recommended next action:"
  echo "  wl academy start"
}

cmd_help() {
  cat <<'HELP'
Usage:
  wl academy status             Show current Academy status
  wl academy today              Show today's lesson dashboard
  wl academy start              Start current lesson
  wl academy lesson             Show current lesson
  wl academy lab                Show current lab
  wl academy quiz               Show current quiz
  wl academy journal            Create/print today's journal path
  wl academy build              Suggest today's Wonderland build task
  wl academy complete           Mark current lesson complete
  wl academy progress           Show progress
  wl academy review             Show review summary
  wl academy generate year-1    Generate year-one lesson/lab/quiz scaffolds
HELP
}

case "${1:-help}" in
  status) cmd_status ;;
  today) cmd_today ;;
  start) cmd_start ;;
  lesson) cmd_lesson ;;
  lab) cmd_lab ;;
  quiz) cmd_quiz ;;
  journal) cmd_journal ;;
  build) cmd_build ;;
  generate) shift || true; cmd_generate "${1:-year-1}" ;;
  complete) cmd_complete ;;
  progress) cmd_progress ;;
  review) cmd_review ;;
  help|*) cmd_help ;;
esac
