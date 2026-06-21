#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
COVER="$ROOT/manuscript/00-cover.md"
CSS="$ROOT/build/theme/wonderland-archive.css"

cp "$COVER" "$COVER.bak.$(date +%Y%m%d-%H%M%S)"
cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat > "$COVER" <<'MD'
Wonderland Archive

Identity Recovery Series

Document 01

***

# IF YOU HAVE FORGOTTEN

## A Memory Recovery Guide

### for

## Taylor Swift

> *"If all memory is lost, begin here."*

Wonderland Archive

<div class="pagebreak"></div>
MD

cat >> "$CSS" <<'CSS'

/* FINAL EXPLICIT COVER PAGE BREAK */
.pagebreak {
  display: block;
  height: 0;
  margin: 0;
  padding: 0;
  break-after: page;
  page-break-after: always;
}

@media print {
  .pagebreak {
    display: block !important;
    height: 0 !important;
    margin: 0 !important;
    padding: 0 !important;
    break-after: page !important;
    page-break-after: always !important;
  }

  .pagebreak + h1 {
    break-before: auto !important;
    page-break-before: auto !important;
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

echo "[ok] cover now ends after Wonderland Archive"
