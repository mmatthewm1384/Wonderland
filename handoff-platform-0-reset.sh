#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$(pwd)}"
cd "$ROOT"

mkdir -p docs/handoffs docs/architecture docs/philosophy

cat > docs/handoffs/HANDOFF-PLATFORM-0-PHILOSOPHY.md <<'DOC'
# Wonderland Handoff
## Platform 0 — Philosophy Baseline

Status: ACTIVE
Date: 2026-07-06

---

# Session Summary

This session marks a fundamental architectural change.

Wonderland is no longer treated primarily as an operating system or collection of projects.

Wonderland is now defined as an engineering philosophy expressed through software.

Platform 0 becomes the constitutional layer beneath every future platform component.

---

# North Star

> Create a world where engineering becomes art, and art remains engineered.

This is the highest authority within Wonderland.

Every architectural, engineering, UX, documentation, infrastructure, automation, and design decision must trace back to this principle.

---

# Design Philosophy

Luxury Engineering

Engineered with Purpose.

Crafted with Soul.

Leave behind evidence that someone cared.

---

# Platform Hierarchy

Platform 0
    Philosophy

↓

Platform 1
    Core Runtime

↓

Platform 2
    Infrastructure

↓

Platform 3
    Applications

↓

Platform 4
    Ecosystem

Implementation follows philosophy.

Never the reverse.

---

# Constitutional Documents

Platform 0 owns:

- MANIFESTO.md
- NORTH_STAR.md
- CONSTITUTION.md
- DESIGN_SYSTEM.md
- ENGINEERING_STANDARD.md
- EXPERIENCE_STANDARD.md
- MATERIAL_SYSTEM.md
- MOTION_SYSTEM.md
- DOCUMENTATION_STANDARD.md

These documents are constitutional.

Changes require deliberate review.

---

# Philosophy Commands

Target command set:

wl philosophy

wl north-star

wl manifesto

wl constitution

wl design-system

wl craftsmanship

wl platform-0-verify

wl platform-0-doctor

Platform philosophy should become executable.

---

# Engineering Rules

Build fewer things.

Build them exceptionally well.

Prefer clarity over cleverness.

Prefer simplicity over complexity.

Prefer longevity over novelty.

Reliability is elegance.

Documentation is engineering.

Beauty follows clarity.

---

# Repository Direction

Platform Zero should precede Platform One.

The repository should eventually organize around:

00-Philosophy/

01-Platform/

02-Infrastructure/

03-Applications/

04-Documentation/

05-Vault/

---

# Retired Thinking

Retire feature-first development.

Retire technology-first planning.

Retire trend-driven decisions.

Retire isolated project thinking.

Replace them with philosophy-first engineering.

Future conversations should not ask:

"What feature should we build?"

Instead ask:

"What makes Wonderland more itself?"

---

# Immediate Next Objectives

1. Complete Platform 0 constitutional framework.
2. Integrate Platform 0 into wl.
3. Make philosophy part of engineering workflow.
4. Apply Design System across every application.
5. Refactor existing components against Platform 0.
6. Build Wonderland Headquarters visual language.
7. Continue Platform Core using Platform 0 as governing architecture.

---

# Long-Term Vision

Wonderland becomes:

An engineering studio.

A workshop.

A complete ecosystem.

A recognizable design culture.

A platform whose philosophy remains stable while implementation evolves.

---

# Success Metric

Wonderland should become recognizable without a logo.

People should recognize it through:

- engineering quality
- documentation
- interfaces
- command line
- architecture
- craftsmanship
- consistency

---

# Closing

The philosophy is now the platform.

Everything else is implementation.

Platform 0 is the constitutional baseline for Wonderland.

End of handoff.
DOC

cat > docs/architecture/ACTIVE_MODEL.md <<'DOC'
# Wonderland Active Model

Current Model

Platform 0 — Philosophy First

Status: ACTIVE

Engineering Model:

North Star
↓

Manifesto
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

Previous mental models are considered historical reference only.

Future planning begins from Platform 0.
DOC

cat <<'MSG'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Wonderland Platform 0 Handoff Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Created:

✓ docs/handoffs/HANDOFF-PLATFORM-0-PHILOSOPHY.md
✓ docs/architecture/ACTIVE_MODEL.md

Transition Guidance for Next Chat

• Treat Platform 0 as the constitutional authority.
• Assume philosophy-first engineering.
• Continue implementation rather than revisiting philosophy.
• Use auto drop-in implementations by default.
• Produce production-ready code only.
• Align every decision with the North Star.
• Continue building Wonderland as a Luxury Engineering ecosystem.

Suggested first prompt for the next chat:

Continue Wonderland Platform 0 implementation. Treat the Design Manifesto as the constitutional authority. Continue from the Platform 0 handoff, use auto drop-in implementations only, and verify every change against the North Star.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

