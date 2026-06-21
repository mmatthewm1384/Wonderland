#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"

echo "[*] Restoring CSS to state before last layout tune"

LATEST_BACKUP="$(ls -t "$CSS".bak.* | head -1)"

if [[ -z "$LATEST_BACKUP" ]]; then
  echo "[-] No CSS backup found"
  exit 1
fi

cp "$LATEST_BACKUP" "$CSS"

echo "[ok] restored from $LATEST_BACKUP"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   MINIMAL REQUESTED FIX ONLY
   1. KNOWN TRUTHS stays below KNOWN TRUTHS APPENDIX.
   2. ALBUM ERA timeline flows naturally with as many eras per page as fit.
   -------------------------------------------------------------------------- */

@media print {
  /* Keep KNOWN TRUTHS directly under KNOWN TRUTHS APPENDIX */
  h2#known-truths {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /* Let album timeline entries flow naturally */
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

"$ROOT/scripts/build/build-book.sh"

pandoc \
  "$ROOT/build/manuscript.md" \
  -s \
  --embed-resources \
  --standalone \
  --css "$CSS" \
  -o "$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"

"$ROOT/scripts/build/wl-archive-pdf-chrome.sh"

echo "[ok] restored previous layout and applied minimal requested fixes"
