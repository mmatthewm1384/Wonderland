#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Wonderland/vault/20-books/if-you-have-forgotten"
CSS="$ROOT/build/theme/wonderland-archive.css"
HTML="$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"
PDF="$ROOT/build/pdf/if-you-have-forgotten-wonderland-archive-final.pdf"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* FINAL MICRO-FIX: keep Known Truths on Known Truths Appendix opener page */
@media print {
  h2#known-truths {
    break-before: avoid-page !important;
    page-break-before: avoid !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
    margin-top: 2rem !important;
  }

  h1#known-truths-appendix + h3 + hr + p + hr {
    break-after: auto !important;
    page-break-after: auto !important;
    margin-bottom: 1.2rem !important;
  }

  h1#known-truths-appendix + h3 + hr + p + hr + h2#known-truths {
    break-before: auto !important;
    page-break-before: auto !important;
    margin-top: 0 !important;
  }
}
CSS

cd "$ROOT"

pandoc \
  build/manuscript.md \
  -s \
  --embed-resources \
  --standalone \
  --css build/theme/wonderland-archive.css \
  -o "$HTML"

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless \
  --disable-gpu \
  --print-to-pdf="$PDF" \
  --print-to-pdf-no-header \
  "file://$HTML"

open "$PDF"

echo "[ok] Known Truths same-page fix applied"
