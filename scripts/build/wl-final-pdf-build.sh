#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"
HTML="$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"
PDF="$ROOT/build/pdf/if-you-have-forgotten-wonderland-archive-final.pdf"

mkdir -p "$ROOT/build/html" "$ROOT/build/pdf"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   FINAL PDF CORRECTIONS
   -------------------------------------------------------------------------- */

@media print {
  @page {
    size: Letter;
    margin: 0.55in;
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
    font-size: 11px;
    line-height: 1.42;
  }

  /* Major sections start pages */
  h1 {
    break-before: page !important;
    page-break-before: always !important;
  }

  h1:first-of-type {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /* Chapter purple dividers: new page except first one after chapter title */
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

  h1#chapter-1 + h2,
  h1#chapter-2 + h2,
  h1#chapter-3 + h2,
  h1#chapter-4 + h2,
  h1#chapter-5 + h2 {
    break-before: auto !important;
    page-break-before: auto !important;
  }

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

  /* Recovery Notes: ORIGIN stays with appendix opener */
  h2#origin {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  h2#creativity,
  h2#resilience,
  h2#relationships,
  h2#identity,
  h2#appendix-closing {
    break-before: page !important;
    page-break-before: always !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /* Known Truths: KNOWN TRUTHS stays with appendix opener */
  h2#known-truths {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /* Album era timeline flows naturally */
  h1#album-era-timeline ~ h2,
  h1#album-era-timeline ~ h3,
  h1#album-era-timeline ~ h4 {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /* Identity graphs start cleanly and stay intact */
  h2[id^="graph-"] {
    break-before: page !important;
    page-break-before: always !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  pre,
  table,
  blockquote {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  pre {
    background: #0B0F14 !important;
    color: #D2DAE4 !important;
    border: 1px solid rgba(0, 229, 255, 0.40) !important;
    font-size: 9px;
    line-height: 1.22;
    white-space: pre;
    overflow: visible;
  }

  p {
    orphans: 3;
    widows: 3;
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
  -o "$HTML"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

"$CHROME" \
  --headless \
  --disable-gpu \
  --print-to-pdf="$PDF" \
  --print-to-pdf-no-header \
  "file://$HTML"

echo "[ok] final PDF built:"
echo "$PDF"
open "$PDF"
