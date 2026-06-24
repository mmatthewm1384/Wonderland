#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Wonderland/vault/20-books/if-you-have-forgotten"
CSS="$ROOT/build/theme/wonderland-archive.css"
HTML="$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"
PDF="$ROOT/build/pdf/if-you-have-forgotten-wonderland-archive-final.pdf"

mkdir -p "$ROOT/build/html" "$ROOT/build/pdf"

if [[ ! -f "$CSS" ]]; then
  echo "[-] Missing CSS: $CSS" >&2
  exit 1
fi

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   FINAL PDF CORRECTIONS — MINIMAL
   -------------------------------------------------------------------------- */

@media print {
  html,
  body {
    background: #05070A !important;
    color: #D2DAE4 !important;
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }

  /* Recovery Notes: ORIGIN stays below appendix opener */
  h2#origin {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /* Known Truths: KNOWN TRUTHS stays below appendix opener */
  h2#known-truths {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /* Album timeline flows naturally */
  h1#album-era-timeline ~ h2,
  h1#album-era-timeline ~ h3,
  h1#album-era-timeline ~ h4 {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }
}
CSS

cd "$ROOT"

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
