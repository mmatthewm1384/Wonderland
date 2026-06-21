#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   RECOVERY NOTES PAGINATION FIX
   Keep ORIGIN with RECOVERY NOTES APPENDIX.
   Start later recovery-note groups at top of page.
   -------------------------------------------------------------------------- */

@media print {
  /* ORIGIN should stay on the same page as RECOVERY NOTES APPENDIX */
  h2#origin {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /* These purple section headers should start at the top of their own pages */
  h2#creativity,
  h2#resilience,
  h2#relationships,
  h2#identity,
  h2#appendix-closing {
    break-before: page !important;
    page-break-before: always !important;
  }

  /* Keep each purple section title with its first recovery note */
  h2#creativity,
  h2#resilience,
  h2#relationships,
  h2#identity,
  h2#appendix-closing {
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

echo "[ok] recovery notes pagination fixed"
