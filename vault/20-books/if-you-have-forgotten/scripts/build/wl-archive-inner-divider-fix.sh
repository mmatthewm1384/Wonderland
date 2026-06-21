#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   FINAL INNER DIVIDER PAGINATION FIX
   Purple inner dividers start new pages EXCEPT the first divider after each H1.
   -------------------------------------------------------------------------- */

@media print {

  /* Major book sections start new pages */
  h1 {
    break-before: page !important;
    page-break-before: always !important;
  }

  h1:first-of-type {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /* Default: purple inner dividers start at top of page */
  h2 {
    break-before: page !important;
    page-break-before: always !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /* First divider immediately after a chapter/appendix title stays with that title */
  h1 + h2 {
    break-before: auto !important;
    page-break-before: auto !important;
    margin-top: 1.1rem !important;
  }

  /* Subtitle under first divider also stays with opener */
  h1 + h2 + h3 {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /* Do not let tiny closing/status lines become stranded pages */
  p:has(+ hr),
  hr + p,
  blockquote,
  pre,
  table {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  /* Keep graph/code blocks intact */
  pre {
    break-before: auto !important;
    page-break-before: auto !important;
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  /* Avoid orphaned headings */
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

echo "[ok] inner divider pagination fixed"
