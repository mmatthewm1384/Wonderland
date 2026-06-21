#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   FINAL WONDERLAND ARCHIVE PRINT FIX
   Force dark PDF output and page splits for # / ## sections.
   -------------------------------------------------------------------------- */

@media print {
  @page {
    size: Letter;
    margin: 0.65in;
    background: #05070A;
  }

  html,
  body {
    background: #05070A !important;
    color: #D2DAE4 !important;
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }

  body {
    padding: 0 !important;
    max-width: none !important;
    font-size: 11.5px;
    line-height: 1.45;
  }

  /* Page split on all # and ## headings */
  h1,
  h2 {
    break-before: page;
    page-break-before: always;
  }

  /* Do not create a blank page before the first title */
  h1:first-of-type {
    break-before: auto;
    page-break-before: auto;
  }

  h1,
  h2,
  h3,
  h4 {
    break-after: avoid;
    page-break-after: avoid;
  }

  p,
  li {
    orphans: 3;
    widows: 3;
  }

  pre,
  table,
  blockquote {
    break-inside: avoid;
    page-break-inside: avoid;
  }

  pre {
    background: #0B0F14 !important;
    color: #D2DAE4 !important;
    border: 1px solid rgba(0, 229, 255, 0.40) !important;
    font-size: 9.5px;
    line-height: 1.25;
    white-space: pre;
    overflow: visible;
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
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

open -a Safari "$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"

echo "[ok] final print CSS applied"
echo "$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"
