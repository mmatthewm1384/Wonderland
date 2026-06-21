#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   RECOVERY NOTES APPENDIX ONLY FIX
   ORIGIN stays below RECOVERY NOTES APPENDIX.
   Later purple recovery-note section titles start at top of page.
   -------------------------------------------------------------------------- */

@media print {
  /* Keep ORIGIN directly under RECOVERY NOTES APPENDIX */
  h2#origin {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /* Later purple section titles start at top of page */
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

echo "[ok] recovery notes appendix-only pagination applied"
