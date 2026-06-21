#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"
HTML="$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"
PDF="$ROOT/build/pdf/if-you-have-forgotten-wonderland-archive-final.pdf"

mkdir -p "$ROOT/build/html" "$ROOT/build/pdf"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* FINAL CHROME PDF EXPORT */
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

  /* Major sections start cleanly */
  h1,
  h2 {
    break-before: page;
    page-break-before: always;
  }

  h1:first-of-type,
  body > p:first-child,
  body > p:first-child + p,
  body > p:first-child + p + p {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /* Keep cover compact and on page one */
  body > p:first-child,
  body > p:first-child + p,
  body > p:first-child + p + p,
  body > hr:first-of-type,
  body > h1:first-of-type,
  body > h1:first-of-type + h2,
  body > h1:first-of-type + h2 + h3 {
    break-before: auto !important;
    page-break-before: auto !important;
    margin-top: 0.45rem !important;
    margin-bottom: 0.45rem !important;
  }

  h1:first-of-type {
    margin-top: 1.1rem !important;
    font-size: 2rem !important;
  }

  h1,
  h2,
  h3,
  h4 {
    break-after: avoid;
    page-break-after: avoid;
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
    font-size: 9px;
    line-height: 1.22;
    white-space: pre;
    overflow: visible;
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

CHROME=""
for candidate in \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  "/Applications/Chromium.app/Contents/MacOS/Chromium" \
  "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
do
  if [[ -x "$candidate" ]]; then
    CHROME="$candidate"
    break
  fi
done

if [[ -z "$CHROME" ]]; then
  echo "[-] No Chrome/Chromium/Edge executable found."
  echo "Install Google Chrome or Chromium, then rerun."
  exit 1
fi

"$CHROME" \
  --headless \
  --disable-gpu \
  --print-to-pdf="$PDF" \
  --print-to-pdf-no-header \
  "file://$HTML"

echo "[ok] PDF built:"
echo "$PDF"

open "$PDF"
