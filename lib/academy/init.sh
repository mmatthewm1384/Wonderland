#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
ACADEMY="$WL_ROOT/academy"

if [[ ! -d "$WL_ROOT" ]]; then
  echo "FAIL Wonderland root not found: $WL_ROOT" >&2
  exit 1
fi

mkdir -p "$ACADEMY"/00-governance/{manifesto,charter,handbook,engineering-standards,assessment-guide,roadmap}
mkdir -p "$ACADEMY"/01-curriculum/templates
mkdir -p "$ACADEMY"/01-curriculum/year-1/{module-01-foundations,module-02-linux,module-03-networking,module-04-programming,module-05-databases,module-06-devops,module-07-security,module-08-ai,module-09-distributed-systems,module-10-desktop-mobile,module-11-platform-architecture,module-12-capstone}
mkdir -p "$ACADEMY"/02-lessons/{day-001-030,day-031-060,day-061-090,day-091-120,day-121-150,day-151-180,day-181-210,day-211-240,day-241-270,day-271-300,day-301-330,day-331-365}
mkdir -p "$ACADEMY"/03-labs/{foundations,linux,networking,programming,databases,devops,security,ai,distributed-systems,desktop-mobile,architecture,capstone}
mkdir -p "$ACADEMY"/04-projects/{wonderland,challenge-projects,capstone}
mkdir -p "$ACADEMY"/05-reference/{glossary,encyclopedia,cheat-sheets,command-reference,design-patterns,algorithms,protocols,standards,bibliography}
mkdir -p "$ACADEMY"/06-diagrams/{computer-science,operating-systems,linux,networking,security,containers,databases,distributed-systems,ai,wonderland}
mkdir -p "$ACADEMY"/07-quizzes/{daily,weekly,module,final}
mkdir -p "$ACADEMY"/08-certifications/{level-1-foundations,level-2-systems,level-3-infrastructure,level-4-platform,level-5-architect}
mkdir -p "$ACADEMY"/09-progress/{journal,portfolio,achievements,tracker,reviews,transcripts}
mkdir -p "$ACADEMY"/10-assets/{images,icons,slides,templates,branding}
mkdir -p "$ACADEMY"/11-app/{specification,ui,api,knowledge-graph,integrations,future-features}
mkdir -p "$ACADEMY"/12-contributors/{author-guide,review-guide,style-guide,release-notes}
mkdir -p "$ACADEMY"/13-automation/{scripts,generators,validation,export}
mkdir -p "$ACADEMY"/14-publications/{books,whitepapers,tutorials,research,presentations}
mkdir -p "$ACADEMY"/archive

cat > "$ACADEMY/README.md" <<'DOC'
# Wonderland Academy

Learn. Build. Verify. Ship.

Wonderland Academy is the learning, onboarding, and certification system for Wonderland OS.
DOC

cat > "$ACADEMY/00-governance/manifesto/MANIFESTO.md" <<'DOC'
# Wonderland Academy Manifesto

Every lesson should produce:

1. A stronger engineer.
2. A stronger Wonderland platform.
3. Better documentation for future learners.
DOC

cat > "$ACADEMY/01-curriculum/templates/LESSON_TEMPLATE.md" <<'DOC'
# Day XXX — Lesson Title

## Objectives
## Core Concepts
## Deep Dive
## Lab
## Wonderland Integration
## Verification
## Quiz
## Reflection
DOC

cat > "$ACADEMY/03-labs/LAB_TEMPLATE.md" <<'DOC'
# Lab Template

## Objective
## Prerequisites
## Steps
## Verification
## Rollback
## Wonderland Improvement
## Reflection
DOC

cat > "$ACADEMY/09-progress/tracker/PROGRESS.md" <<'DOC'
# Wonderland Academy Progress

Current Day:
Current Module:
Lessons Completed:
Labs Completed:
Wonderland Improvements:
Next Goal:
DOC

echo "PASS academy initialized: $ACADEMY"
