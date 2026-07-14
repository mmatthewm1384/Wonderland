#!/usr/bin/env bash
set -euo pipefail

##############################################################################
#
# Wonderland Platform 0
#
# Constitutional Installer
#
##############################################################################

ROOT="${WL_ROOT:-$(pwd)}"

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "          Wonderland Platform 0 Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

mkdir -p "$ROOT"/docs/philosophy
mkdir -p "$ROOT"/docs/releases
mkdir -p "$ROOT"/docs/standards
mkdir -p "$ROOT"/docs/design

##############################################################################
#
# Platform Registry
#
##############################################################################

cat > "$ROOT/docs/philosophy/platform.json" <<JSON
{
  "platform":"0.0",
  "name":"Wonderland Philosophy",
  "status":"released",
  "north_star":"Create a world where engineering becomes art, and art remains engineered.",
  "codename":"Luxury Engineering",
  "constitutional":true
}
JSON

##############################################################################
#
# Philosophy Registry
#
##############################################################################

cat > "$ROOT/docs/philosophy/README.md" <<'DOC'
# Wonderland Philosophy

Platform Zero.

Everything begins here.

Contents:

- NORTH_STAR.md
- MANIFESTO.md
- CONSTITUTION.md
- DESIGN_SYSTEM.md
- ENGINEERING_STANDARD.md
- EXPERIENCE_STANDARD.md
- MATERIAL_SYSTEM.md
- MOTION_SYSTEM.md
- DOCUMENTATION_STANDARD.md

Nothing above this directory.

Everything below it.
DOC

##############################################################################
#
# Engineering Standard
#
##############################################################################

cat > "$ROOT/docs/standards/ENGINEERING_STANDARD.md" <<'DOC'
# Wonderland Engineering Standard

Every change must be:

Reliable.

Recoverable.

Observable.

Maintainable.

Understandable.

Documented.

Consistent.

Beautiful.

Beauty means clarity.

Never decoration.
DOC

##############################################################################
#
# Experience Standard
#
##############################################################################

cat > "$ROOT/docs/standards/EXPERIENCE_STANDARD.md" <<'DOC'
# Wonderland Experience Standard

Interfaces should feel:

Calm.

Confident.

Focused.

Quiet.

Purposeful.

Technology should disappear behind craftsmanship.
DOC

##############################################################################
#
# Material System
#
##############################################################################

cat > "$ROOT/docs/design/MATERIAL_SYSTEM.md" <<'DOC'
# Wonderland Material System

Primary Materials

• Carbon Fiber

• Brushed Aluminum

• Glass

• Titanium

• Matte Ceramic

• Alcantara

• Walnut

Interfaces should feel machined.

Not decorated.
DOC

##############################################################################
#
# Motion System
#
##############################################################################

cat > "$ROOT/docs/design/MOTION_SYSTEM.md" <<'DOC'
# Wonderland Motion

Motion should resemble:

Precision machinery.

Camera sliders.

Formula 1 telemetry.

CNC equipment.

Accelerate.

Settle.

Stop.

No unnecessary movement.
DOC

##############################################################################
#
# Documentation Standard
#
##############################################################################

cat > "$ROOT/docs/standards/DOCUMENTATION_STANDARD.md" <<'DOC'
# Documentation Standard

Documentation is engineering.

Write for the engineer who arrives five years later.

Teach.

Explain.

Preserve knowledge.

Reduce uncertainty.

Respect the reader.
DOC

##############################################################################
#
# Philosophy Summary
#
##############################################################################

cat <<EOF2

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Wonderland Platform 0 Installed

Platform Zero now governs:

✓ Engineering

✓ Design

✓ Documentation

✓ Motion

✓ Materials

✓ Experience

✓ Philosophy

North Star:

"Create a world where engineering becomes art,
and art remains engineered."

Everything else is implementation.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF2
