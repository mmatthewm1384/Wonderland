#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$(pwd)}"
cd "$ROOT"

mkdir -p docs/handoffs docs/architecture docs/philosophy docs/archive/models

STAMP="$(date +%Y%m%d-%H%M%S)"

cat > docs/architecture/ACTIVE_MODEL.md <<'DOC'
# Wonderland Active Model

**Status:** ACTIVE  
**Model:** Platform 0 — Philosophy First  
**Authority:** Wonderland Design Manifesto  
**North Star:** Create a world where engineering becomes art, and art remains engineered.

---

## Current Governing Model

Wonderland is an engineering philosophy expressed through software.

Implementation follows philosophy.

Never the reverse.

---

## Authority Chain

```text
North Star
    ↓
Design Manifesto
    ↓
Constitution
    ↓
Design System
    ↓
Engineering Standards
    ↓
Architecture
    ↓
Implementation
Retired / Superseded Models

Previous models are historical reference only.

They do not govern future architecture unless explicitly reintroduced through Platform 0 review.

Superseded mental models include:

Feature-first development
Technology-first planning
Trend-driven design
Isolated project thinking
OS-first identity
Toolchain-first identity
App-first identity
Current Planning Question

Do not begin with:

What feature should we build?

Begin with:

What makes Wonderland more itself?

Final Rule

Every major decision must trace back to the North Star.
DOC

cat > docs/handoffs/HANDOFF-PLATFORM-0-PHILOSOPHY.md <<'DOC'

Wonderland Handoff — Platform 0 Philosophy Baseline

Status: ACTIVE
Date: 2026-07-06
Model: Platform 0 — Philosophy First
Codename: Luxury Engineering

Summary

This handoff establishes Platform 0 as the constitutional foundation of Wonderland.

Wonderland is no longer governed primarily as an operating system, toolchain, application suite, or infrastructure project.

Wonderland is now governed as:

An engineering philosophy expressed through software.

The philosophy is the platform.

Everything else is implementation.

North Star

Create a world where engineering becomes art, and art remains engineered.

Every architectural, engineering, UX, documentation, automation, infrastructure, and design decision must trace back to this principle.

Core Language
Luxury Engineering
Engineered with Purpose
Crafted with Soul
Leave behind evidence that someone cared
Care is architecture
Beauty follows clarity
Reliability is elegance
Documentation is engineering
Active Platform Hierarchy
Platform 0
  Philosophy

Platform 1
  Core Runtime

Platform 2
  Infrastructure

Platform 3
  Applications

Platform 4
  Ecosystem

Platform 0 governs all later platform layers.

Constitutional Documents

Platform 0 owns and governs:

NORTH_STAR.md
MANIFESTO.md
CONSTITUTION.md
DESIGN_SYSTEM.md
docs/standards/ENGINEERING_STANDARD.md
docs/standards/EXPERIENCE_STANDARD.md
docs/standards/DOCUMENTATION_STANDARD.md
docs/design/MATERIAL_SYSTEM.md
docs/design/MOTION_SYSTEM.md

These documents are constitutional artifacts.

They should change rarely and only through deliberate review.

Executable Philosophy Commands

Target command set:

wl philosophy
wl north-star
wl manifesto
wl constitution
wl design-system
wl craftsmanship
wl platform-0-verify
wl platform-0-doctor

The philosophy should be executable, inspectable, and verifiable.

Retired / Superseded Thinking

The following models are superseded:

Feature-first development
Technology-first planning
Trend-driven design
Isolated project thinking
OS-first identity
App-first identity
Toolchain-first identity

Future planning should not start with:

What should we build?

Future planning should start with:

What makes Wonderland more itself?

Engineering Rules
Build fewer things.
Build them exceptionally well.
Prefer clarity over cleverness.
Prefer simplicity over complexity.
Prefer longevity over novelty.
Prefer craftsmanship over convenience.
Prefer trust over spectacle.
Reliability is elegance.
Documentation is engineering.
Beauty follows clarity.
Leave every system better than you found it.
Immediate Next Objectives
Complete Platform 0 constitutional documents.
Verify Platform 0 with wl platform-0-doctor.
Integrate philosophy commands into wl.
Apply Manifesto Check to future pull requests.
Refactor CLI output to match Luxury Engineering style.
Apply Design System to current apps and dashboards.
Create 00-Philosophy/ structure when repository reorganization is safe.
Continue Platform Core using Platform 0 as governing architecture.
Next Chat Prompt

Continue Wonderland Platform 0 implementation.

Treat the Design Manifesto as the constitutional authority.

Use the Platform 0 handoff as the active model.

Use auto drop-in implementations only.

Verify every change against the North Star.

Do not revisit old planning models unless explicitly requested.

Continue implementation.
DOC

cat > docs/archive/models/RETIRED-MODELS-$STAMP.md <<'DOC'

Retired Wonderland Planning Models

Status: Historical Reference
Superseded By: Platform 0 — Philosophy First

Superseded Models

The following models are retired as governing architecture:

Feature-first Wonderland
OS-first Wonderland
Toolchain-first Wonderland
App-suite-first Wonderland
Trend-driven Wonderland
Isolated-project Wonderland

These ideas may remain useful historically, but they no longer define the project.

Active Replacement

Wonderland is now governed by Platform 0:

Create a world where engineering becomes art, and art remains engineered.

Rule

Previous models may inform context.

They may not override the North Star.
DOC

cat > docs/philosophy/NEXT_CHAT.md <<'DOC'

Next Chat Bootstrap

Continue Wonderland Platform 0 implementation.

Use these assumptions:

Platform 0 is active.
The Design Manifesto is the constitutional authority.
Previous models are retired / superseded.
Use auto drop-in implementations by default.
Produce production-ready code.
Verify changes.
Align everything with the North Star.

North Star:

Create a world where engineering becomes art, and art remains engineered.
DOC

cat <<MSG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Platform 0 Handoff Implemented
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Created / updated:

✓ docs/architecture/ACTIVE_MODEL.md
✓ docs/handoffs/HANDOFF-PLATFORM-0-PHILOSOPHY.md
✓ docs/archive/models/RETIRED-MODELS-$STAMP.md
✓ docs/philosophy/NEXT_CHAT.md

Next:

git add docs/architecture docs/handoffs docs/archive docs/philosophy
git commit -m "retire old models and establish Platform 0 handoff"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MSG
