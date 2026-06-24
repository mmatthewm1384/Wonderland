#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Wonderland/vault/20-books/if-you-have-forgotten"
CSS="$ROOT/build/theme/wonderland-archive.css"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   ALBUM ERA BLOCK FIX
   Prevent ERA blocks from splitting across pages.
   -------------------------------------------------------------------------- */

@media print {
  h2[id^="era-"] {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  h2[id^="era-"] + h3,
  h2[id^="era-"] + h3 + h4,
  h2[id^="era-"] + h3 + h4 + p,
  h2[id^="era-"] + h3 + h4 + p + p,
  h2[id^="era-"] + h3 + h4 + p + p + p,
  h2[id^="era-"] + h3 + h4 + p + p + p + p,
  h2[id^="era-"] + h3 + h4 + p + p + p + p + p {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  h2[id^="era-"],
  h2[id^="era-"] + h3,
  h2[id^="era-"] + h3 + h4 {
    break-after: avoid !important;
    page-break-after: avoid !important;
  }
}
CSS

cd "$ROOT"

./scripts/build/build-book.sh

pandoc \
  build/manuscript.md \
  -s \
  --embed-resources \
  --standalone \
  --css build/theme/wonderland-archive.css \
  -o build/html/if-you-have-forgotten-wonderland-archive-final.html

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless \
  --disable-gpu \
  --print-to-pdf="build/pdf/if-you-have-forgotten-wonderland-archive-final.pdf" \
  --print-to-pdf-no-header \
  "file://$(pwd)/build/html/if-you-have-forgotten-wonderland-archive-final.html"

open build/pdf/if-you-have-forgotten-wonderland-archive-final.pdf

echo "[ok] album era block pagination fixed"
