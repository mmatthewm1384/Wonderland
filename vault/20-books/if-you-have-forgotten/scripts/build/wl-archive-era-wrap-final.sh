#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Wonderland/vault/20-books/if-you-have-forgotten"
CSS="$ROOT/build/theme/wonderland-archive.css"
HTML="$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"
PDF="$ROOT/build/pdf/if-you-have-forgotten-wonderland-archive-final.pdf"

cd "$ROOT"

./scripts/build/build-book.sh

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

cat >> "$CSS" <<'CSS'

/* FINAL ERA BLOCK FIX — CSS BEFORE PANDOC EMBED */
@media print {
  .era-block {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
    break-before: page !important;
    page-break-before: always !important;
    margin-top: 0 !important;
  }

  .era-block h2,
  .era-block h3,
  .era-block h4,
  .era-block p {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  .era-block h2,
  .era-block h3,
  .era-block h4 {
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  .era-block p {
    margin-top: 0.45rem !important;
    margin-bottom: 0.45rem !important;
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

python3 <<'PY'
from pathlib import Path
import re

p = Path("build/html/if-you-have-forgotten-wonderland-archive-final.html")
html = p.read_text()

pattern = re.compile(
    r'(<h2 id="era-[^"]+">.*?</h2>.*?)(?=<h2 id="era-|<h2 id="evolution-graph"|<h2 id="what-the-eras-reveal"|<h1 id=|</body>)',
    re.S
)

html = pattern.sub(lambda m: f'<section class="era-block">\n{m.group(1)}\n</section>\n', html)

p.write_text(html)
PY

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless \
  --disable-gpu \
  --print-to-pdf="$PDF" \
  --print-to-pdf-no-header \
  "file://$HTML"

open "$PDF"

echo "[ok] final era wrap applied"
