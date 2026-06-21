#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   CHAPTER DIVIDER ONLY FIX
   Chapter purple dividers start at top of page,
   except the first ## after each chapter title.
   -------------------------------------------------------------------------- */

@media print {
  /* Chapter body dividers */
  h1#chapter-1 ~ h2,
  h1#chapter-2 ~ h2,
  h1#chapter-3 ~ h2,
  h1#chapter-4 ~ h2,
  h1#chapter-5 ~ h2 {
    break-before: page !important;
    page-break-before: always !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /* First divider below each chapter title stays on chapter opener page */
  h1#chapter-1 + h2,
  h1#chapter-2 + h2,
  h1#chapter-3 + h2,
  h1#chapter-4 + h2,
  h1#chapter-5 + h2 {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /* Keep subtitle below first divider */
  h1#chapter-1 + h2 + h3,
  h1#chapter-2 + h2 + h3,
  h1#chapter-3 + h2 + h3,
  h1#chapter-4 + h2 + h3,
  h1#chapter-5 + h2 + h3 {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
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

echo "[ok] chapter divider-only pagination applied"
