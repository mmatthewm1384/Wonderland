#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"
COVER="$ROOT/manuscript/00-cover.md"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"
cp "$COVER" "$COVER.bak.$(date +%Y%m%d-%H%M%S)"

cat > "$COVER" <<'MD'
Wonderland Archive

Identity Recovery Series

Document 01

***

# IF YOU HAVE FORGOTTEN

## A Memory Recovery Guide

### for

## Taylor Swift

> *"If all memory is lost, begin here."*

Wonderland Archive
MD

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   FINAL COVER PAGE FIX
   Keep archive cover together on page one.
   -------------------------------------------------------------------------- */

@media print {
  body > p:first-child,
  body > p:nth-child(2),
  body > p:nth-child(3),
  body > hr:first-of-type,
  body > h1:first-of-type,
  body > h1:first-of-type + h2,
  body > h1:first-of-type + h2 + h3,
  body > h1:first-of-type + h2 + h3 + h2,
  body > blockquote:first-of-type {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: auto !important;
    page-break-after: auto !important;
  }

  body > h1:first-of-type {
    margin-top: 1.2rem !important;
    font-size: 2.5rem !important;
  }

  body > h1:first-of-type + h2 {
    color: var(--wl-purple) !important;
    margin-top: 1rem !important;
  }

  body > h1:first-of-type + h2 + h3 {
    color: var(--wl-green) !important;
    margin-top: 1rem !important;
  }
}
CSS

"$ROOT/scripts/build/wl-archive-pdf-chrome.sh"

echo "[ok] final cover implemented"
