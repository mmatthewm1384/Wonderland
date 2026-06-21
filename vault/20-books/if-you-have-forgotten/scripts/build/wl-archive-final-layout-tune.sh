#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* --------------------------------------------------------------------------
   FINAL LAYOUT TUNE
   Targeted pagination for archive PDF.
   -------------------------------------------------------------------------- */

@media print {

  /*
    Global rule:
    H1 starts new major sections.
    H2 does NOT globally force pages anymore.
  */
  h1 {
    break-before: page !important;
    page-break-before: always !important;
  }

  h1:first-of-type {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  h2 {
    break-before: auto !important;
    page-break-before: auto !important;
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  h3,
  h4 {
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /*
    Keep first inner title directly under its H1 opener.
    Example:
    CHAPTER 1
    THE GIRL BEFORE THE MYTH
    Who You Were Before Anyone Was Watching
  */
  h1 + h2,
  h1 + h2 + h3 {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /*
    Chapter internal purple dividers:
    start at top of page, except the first H2 after each H1.
  */
  body:not(.appendix) h2:not(h1 + h2) {
    break-before: page;
    page-break-before: always;
  }

  /*
    Explicit appendix/timeline overrides.
    These must NOT become title-only pages.
  */
  h1#recovery-notes-appendix + h3,
  h1#recovery-notes-appendix + h3 + hr,
  h1#recovery-notes-appendix + h3 + hr + p,
  h2#origin {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  h1#known-truths-appendix + h3,
  h1#known-truths-appendix + h3 + hr,
  h1#known-truths-appendix + h3 + hr + p,
  h2#known-truths {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /*
    Known Truth sections can start fresh after the intro.
  */
  h2#section-i,
  h2#section-ii,
  h2#section-iii,
  h2#section-iv,
  h2#section-v,
  h2#section-vi,
  h2#section-vii,
  h2#final-truth,
  h2#known-truths-status {
    break-before: page !important;
    page-break-before: always !important;
  }

  /*
    Recovery Notes group headers.
    ORIGIN stays with appendix opener.
    Later groups start on top of pages.
  */
  h2#creativity,
  h2#resilience,
  h2#relationships,
  h2#identity,
  h2#appendix-closing {
    break-before: page !important;
    page-break-before: always !important;
  }

  /*
    Album era timeline:
    Do not force each era to its own page.
    Let as many eras fit naturally as possible.
  */
  h1#album-era-timeline ~ h2,
  h1#album-era-timeline ~ h3,
  h1#album-era-timeline ~ h4 {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  /*
    But keep each album/era heading with its immediate content.
  */
  h1#album-era-timeline ~ h2,
  h1#album-era-timeline ~ h3,
  h1#album-era-timeline ~ h4 {
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  /*
    Identity graphs:
    each graph starts cleanly and keeps graph body intact.
  */
  h2[id^="graph-"] {
    break-before: page !important;
    page-break-before: always !important;
  }

  h2[id^="graph-"] + h3,
  h2[id^="graph-"] + h3 + pre,
  pre {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  /*
    Reduce orphan status-marker pages.
  */
  p {
    orphans: 3;
    widows: 3;
  }

  blockquote,
  pre,
  table {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
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

echo "[ok] final layout tune applied"
