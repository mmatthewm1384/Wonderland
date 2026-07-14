#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$(pwd)}"
cd "$ROOT"

mkdir -p \
    docs/philosophy \
    docs/governance \
    docs/templates \
    config/platform0 \
    bin

###############################################################################
# GOVERNANCE CHARTER
###############################################################################

cat > docs/governance/PLATFORM0_GOVERNANCE.md <<'DOC'
# Platform 0 Governance

Platform 0 is the constitutional authority of Wonderland.

Nothing supersedes Platform 0 except an explicit constitutional revision.

## Decision Order

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

---

## Every proposal answers:

1. Does it support the North Star?

2. Does it improve Wonderland?

3. Does it reduce complexity?

4. Does it improve craftsmanship?

5. Would the future maintainer thank us?

If any answer is No...

Continue refining.
DOC

###############################################################################
# DESIGN REVIEW TEMPLATE
###############################################################################

cat > docs/templates/DESIGN_REVIEW.md <<'DOC'
# Wonderland Design Review

Project:

Author:

Date:

---

## Problem

Describe the problem.

---

## Solution

Describe the proposed solution.

---

## Manifesto Check

□ Engineering with Purpose

□ Crafted with Soul

□ Improves Wonderland

□ Simpler than before

□ Easier to maintain

□ Easier to understand

---

## North Star Alignment

How does this move Wonderland closer to:

> Create a world where engineering becomes art,
> and art remains engineered?

DOC

###############################################################################
# PLATFORM 0 CONFIG
###############################################################################

cat > config/platform0/platform0.json <<'JSON'
{
  "platform": "0.0",
  "name": "Platform Zero",
  "authority": "constitutional",
  "north_star": "Create a world where engineering becomes art, and art remains engineered.",
  "status": "active",
  "engineering_model": "philosophy-first"
}
JSON

###############################################################################
# WL GOVERNANCE
###############################################################################

cat > bin/wl-governance <<'SH'
#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF2'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Wonderland Governance

Platform 0 : ACTIVE

Authority Chain

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

Rule:

No implementation may contradict Platform 0.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF2
SH

chmod +x bin/wl-governance

###############################################################################
# WL REVIEW
###############################################################################

cat > bin/wl-review <<'SH'
#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF2'
Wonderland Engineering Review

Ask before every merge:

[ ] Solves a meaningful problem

[ ] Improves Wonderland

[ ] Simpler than before

[ ] Reliable

[ ] Recoverable

[ ] Observable

[ ] Maintainable

[ ] Documented

[ ] Consistent with Platform 0

If any answer is NO...

Continue refining.
EOF2
SH

chmod +x bin/wl-review

###############################################################################
# PLATFORM STATUS
###############################################################################

cat <<'EOF2'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Platform 0 Governance Installed

Created:

✓ docs/governance/PLATFORM0_GOVERNANCE.md

✓ docs/templates/DESIGN_REVIEW.md

✓ config/platform0/platform0.json

✓ bin/wl-governance

✓ bin/wl-review

Platform 0 now governs:

• Architecture

• Design

• Engineering

• Documentation

• Applications

• Infrastructure

• Future Releases

Next milestone:

Platform 1 — Core Runtime Refactoring

Everything from this point forward should be evaluated
against Platform 0 before implementation.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF2

