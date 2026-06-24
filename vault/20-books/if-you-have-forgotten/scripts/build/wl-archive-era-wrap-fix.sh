#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Wonderland/vault/20-books/if-you-have-forgotten"
HTML="$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"
PDF="$ROOT/build/pdf/if-you-have-forgotten-wonderland-archive-final.pdf"
CSS="$ROOT/build/theme/wonderland-archive.css"

cd "$ROOT"

./scripts/build/build-book.sh

pandoc \
  build/manuscript.md \
  -s \
  --embed-resources \
  --standalone \
  --css build/theme/wonderland-archive.css \
  -o "$HTML"

python3 <<'PY'
from pathlib import Path
import re

html_path = Path("build/html/if-you-have-forgotten-wonderland-archive-final.html")
html = html_path.read_text()

# Wrap each ERA h2 section until the next ERA h2 or next major h1.
pattern = re.compile(
    r'(<h2 id="era-[^"]+">.*?</h2>)(.*?)(?=<h2 id="era-|<h1 id=|</body>)',
    re.S
)

def wrap(match):
    return f'<section class="era-block">\n{match.group(1)}{match.group(2)}\n</section>\n'

html = pattern.sub(wrap, html)
html_path.write_text(html)
PY

cat >> "$CSS" <<'CSS'

/* FINAL ERA WRAP FIX */
@media print {
  .era-block {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  .era-block h2,
  .era-block h3,
  .era-block h4 {
    break-after: avoid !important;
    page-break-after: avoid !important;
  }
}
CSS

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless \
  --disable-gpu \
  --print-to-pdf="$PDF" \
  --print-to-pdf-no-header \
  "file://$HTML"

open "$PDF"

echo "[ok] era sections wrapped and PDF rebuilt"
