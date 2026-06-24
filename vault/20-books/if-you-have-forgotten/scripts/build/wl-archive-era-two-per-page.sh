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

/* FINAL ERA TWO-PER-PAGE FIX */
@media print {
  .era-pair {
    break-before: page !important;
    page-break-before: always !important;
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  .era-pair:first-of-type {
    break-before: auto !important;
    page-break-before: auto !important;
  }

  .era-pair .era-block {
    break-before: auto !important;
    page-break-before: auto !important;
    break-inside: avoid !important;
    page-break-inside: avoid !important;
    margin-bottom: 2.2rem !important;
  }

  .era-pair .era-block h2,
  .era-pair .era-block h3,
  .era-pair .era-block h4 {
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  .era-pair .era-block p {
    margin-top: 0.35rem !important;
    margin-bottom: 0.35rem !important;
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

era_re = re.compile(
    r'(<h2 id="era-[^"]+">.*?</h2>.*?)(?=<h2 id="era-|<h2 id="evolution-graph"|<h2 id="what-the-eras-reveal"|<h1 id=|</body>)',
    re.S
)

eras = era_re.findall(html)

def make_pairs(blocks):
    out = []
    for i in range(0, len(blocks), 2):
        pair = blocks[i:i+2]
        wrapped = "\n".join(f'<section class="era-block">\n{b}\n</section>' for b in pair)
        out.append(f'<section class="era-pair">\n{wrapped}\n</section>')
    return "\n".join(out)

html = era_re.sub("__ERA_BLOCK_PLACEHOLDER__", html)
html = html.replace("__ERA_BLOCK_PLACEHOLDER__", make_pairs(eras), 1)
html = html.replace("__ERA_BLOCK_PLACEHOLDER__", "")

p.write_text(html)
PY

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless \
  --disable-gpu \
  --print-to-pdf="$PDF" \
  --print-to-pdf-no-header \
  "file://$HTML"

open "$PDF"

echo "[ok] album eras grouped two per page"
