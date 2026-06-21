#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   FINAL PAGE COMBINE FIX
   H1 starts new pages. H2 stays with its section instead of creating blanks.
   -------------------------------------------------------------------------- */

@media print {
  /* Only top-level book boundaries force page breaks */
  h1 {
    break-before: page !important;
    page-break-before: always !important;
  }

  h1:first-of-type {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /* Do NOT force every ## onto a new page */
  h2 {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /* Keep chapter title/subtitle blocks together */
  h1 + h2,
  h1 + h2 + h3,
  h2 + h3 {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /* Avoid blank title-only pages where possible */
  h1, h2, h3, h4 {
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /* Keep small closing/status sections together */
  hr,
  blockquote,
  pre,
  table {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }
}
CSS

"$ROOT/scripts/build/build-book.sh"

pandoc \
  "$ROOT/build/manuscript.md" \
  -s \
  --embed-resources \
  --standalone \
  --css "$CSS" \
  -o "$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"

"$ROOT/scripts/build/wl-archive-pdf-chrome.sh"

echo "[ok] page combine fix applied"
