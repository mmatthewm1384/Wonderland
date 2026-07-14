#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"
cd "$WL_ROOT"

mkdir -p docs/philosophy docs/releases

cat > docs/releases/PLATFORM-0.0-PHILOSOPHY-RELEASE.md <<'DOC'
# Wonderland Platform 0.0 — The Philosophy Release

**Release Name:** Platform 0.0 — The Philosophy Release  
**Status:** Constitutional Baseline  
**Codename:** Luxury Engineering  
**Release Date:** July 6, 2026

---

## Overview

Platform 0.0 is the first constitutional release of Wonderland.

It contains no new software, infrastructure, or features.

It establishes the philosophy that guides every future architectural, engineering, design, documentation, and product decision.

---

## The North Star

> **Create a world where engineering becomes art, and art remains engineered.**

Every decision made within Wonderland should move the platform closer to this objective.

---

## Mission

Wonderland exists to create a complete engineering ecosystem where craftsmanship, reliability, clarity, and beauty reinforce one another.

Software is only one expression of this philosophy.

Infrastructure, documentation, automation, artificial intelligence, industrial design, workspaces, architecture, hardware concepts, education, and research all belong to Wonderland.

---

## Vision

Create an engineering studio whose work is immediately recognizable, not because of a logo, but because of its philosophy.

Every command, interface, document, animation, wallpaper, service, and release should leave behind evidence that someone cared.

---

## Core Values

### Care

Care is the foundation of engineering.

Reliable systems, clear documentation, thoughtful interfaces, and beautiful engineering are all acts of care.

### Craftsmanship

Craftsmanship is the disciplined pursuit of continual improvement.

It values refinement over speed, longevity over novelty, purpose over decoration, and understanding over cleverness.

### Clarity

Complexity belongs inside the system.

Clarity belongs at the interface.

### Stewardship

Every builder inherits Wonderland, improves it, and leaves it stronger for those who follow.

### Trust

Trust is Wonderland's most valuable product.

Every command, document, and release either strengthens trust or weakens it.

---

## Luxury Engineering

Luxury Engineering is not a visual style.

It is an engineering philosophy.

Luxury means reliability, precision, restraint, consistency, longevity, intentionality, and craftsmanship.

Luxury is not excess.

Luxury is care made visible.

---

## Constitutional Principles

1. The Design Manifesto is the North Star.
2. Engineering exists to serve people.
3. Craftsmanship is never optional.
4. Simplicity is preferred over unnecessary complexity.
5. Reliability is elegance.
6. Documentation is engineering.
7. Design communicates values.
8. Every system should become easier to understand over time.
9. Build fewer things. Build them exceptionally well.
10. Leave every system better than you found it.

---

## The Wonderland Test

Every proposal, feature, design, and architectural decision must answer:

- Does this solve a meaningful problem?
- Is this the best engineering we know how to produce?
- Does this move Wonderland closer to its North Star?

If the answer to any question is **No**, continue refining.

---

## Deliverables

Platform 0.0 establishes the constitutional documents of Wonderland:

- `MANIFESTO.md`
- `NORTH_STAR.md`
- `CONSTITUTION.md`
- `DESIGN_SYSTEM.md`
- `ENGINEERING_STANDARD.md`
- `EXPERIENCE_STANDARD.md`
- `MATERIAL_SYSTEM.md`
- `MOTION_SYSTEM.md`
- `DOCUMENTATION_STANDARD.md`

These are constitutional artifacts and should change only through deliberate review.

---

## Release Declaration

Platform 0.0 is not a software release.

Platform 0.0 is the release of Wonderland's identity.

Technology will change.

Languages will change.

Frameworks will change.

Operating systems will change.

The philosophy will remain.

---

## Closing Statement

We do not build software.

We build confidence.

We do not pursue perfection.

We pursue craftsmanship.

We do not chase attention.

We earn trust.

We engineer with purpose.

We craft with soul.

We leave behind evidence that someone cared.

This is Wonderland.

**Wonderland Platform 0.0 — The Philosophy Release**

**Status:** Released.
DOC

cat > docs/philosophy/NORTH_STAR.md <<'DOC'
# Wonderland North Star

> **Create a world where engineering becomes art, and art remains engineered.**

Everything else is implementation.
DOC

cat > NORTH_STAR.md <<'DOC'
# Wonderland North Star

> **Create a world where engineering becomes art, and art remains engineered.**

Everything else is implementation.
DOC

cp docs/releases/PLATFORM-0.0-PHILOSOPHY-RELEASE.md PLATFORM-0.0-PHILOSOPHY-RELEASE.md

cat <<'DONE'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Wonderland Platform 0.0 Installed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Created:

✓ PLATFORM-0.0-PHILOSOPHY-RELEASE.md
✓ NORTH_STAR.md
✓ docs/releases/PLATFORM-0.0-PHILOSOPHY-RELEASE.md
✓ docs/philosophy/NORTH_STAR.md

Next:

git add PLATFORM-0.0-PHILOSOPHY-RELEASE.md NORTH_STAR.md docs/releases docs/philosophy
git commit -m "establish Platform 0.0 philosophy release"
git tag platform-0.0-philosophy

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DONE
