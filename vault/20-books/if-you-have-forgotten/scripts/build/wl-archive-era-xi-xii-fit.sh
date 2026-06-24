#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Wonderland/vault/20-books/if-you-have-forgotten"
CSS="$ROOT/build/theme/wonderland-archive.css"
HTML="$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"
PDF="$ROOT/build/pdf/if-you-have-forgotten-wonderland-archive-final.pdf"

cd "$ROOT"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   ERA XI + ERA XII FIT FIX
   Keep final two album eras together on one page.
   -------------------------------------------------------------------------- */

@media print {
  .era-pair:last-of-type {
    break-before: page !important;
    page-break-before: always !important;
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  .era-pair:last-of-type .era-block {
    margin-bottom: 0.8rem !important;
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  .era-pair:last-of-type .era-block h2,
  .era-pair:last-of-type .era-block h3,
  .era-pair:last-of-type .era-block h4 {
    margin-top: 0.35rem !important;
    margin-bottom: 0.35rem !important;
  }

  .era-pair:last-of-type .era-block p {
    margin-top: 0.12rem !important;
    margin-bottom: 0.12rem !important;
    line-height: 1.2 !important;
  }
}
CSS

pandoc \
  build/manuscript.md \
  -s \
  --embed-resources \
  --standalone \
  --css "$CSS" \
  -o "$HTML"

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless \
  --disable-gpu \
  --print-to-pdf="$PDF" \
  --print-to-pdf-no-header \
  "file://$HTML"

open "$PDF"

echo "[ok] ERA XI and ERA XII fit fix applied"
