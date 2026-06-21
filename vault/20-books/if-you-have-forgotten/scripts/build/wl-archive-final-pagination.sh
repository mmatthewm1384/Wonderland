#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   FINAL PAGINATION CONTROL
   -------------------------------------------------------------------------- */

@media print {

  /* Cover stays together through Taylor Swift */
  body > p:nth-of-type(1),
  body > p:nth-of-type(2),
  body > p:nth-of-type(3),
  body > hr:first-of-type,
  body > h1:first-of-type,
  body > h1:first-of-type + h2,
  body > h1:first-of-type + h2 + h3,
  body > h1:first-of-type + h2 + h3 + h2 {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  body > h1:first-of-type {
    margin-top: 1rem !important;
    font-size: 2.55rem !important;
  }

  body > h1:first-of-type + h2,
  body > h1:first-of-type + h2 + h3,
  body > h1:first-of-type + h2 + h3 + h2 {
    margin-top: 1rem !important;
    margin-bottom: 1rem !important;
  }

  /* Only top-level book parts force new pages */
  h1 {
    break-before: page !important;
    page-break-before: always !important;
  }

  h1:first-of-type {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /* Important appendix/section opener pages */
  h2 {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  h2:has(+ h3),
  h2:has(+ p),
  h2:has(+ pre) {
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /* These sections should remain as opening blocks */
  h2[id^="section-"],
  h2[id="known-truths"],
  h2[id="origin"],
  h2[id^="graph-"] {
    break-before: page !important;
    page-break-before: always !important;
  }

  /* Each identity graph gets its own page */
  h2[id^="graph-"] {
    break-before: page !important;
    page-break-before: always !important;
  }

  h2[id^="graph-"] + h3,
  h2[id^="graph-"] + h3 + pre {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /* Keep graph blocks intact */
  pre {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
    max-height: none !important;
  }

  /* Avoid stranded headings */
  h1, h2, h3, h4 {
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

echo "[ok] final pagination applied"
