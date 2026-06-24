#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Wonderland/vault/20-books/if-you-have-forgotten"
HTML="$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"
PDF="$ROOT/build/pdf/if-you-have-forgotten-wonderland-archive-final.pdf"

python3 <<'PY'
from pathlib import Path
import re

p = Path("build/html/if-you-have-forgotten-wonderland-archive-final.html")
html = p.read_text()

html = re.sub(
    r'(<section class="era-pair">\s*<section class="era-block">\s*<h2 id="era-xi">.*?</section>\s*<section class="era-block">\s*<h2 id="era-xii">.*?</section>\s*</section>)',
    r'<section class="era-pair final-era-pair">\1</section>',
    html,
    flags=re.S
)

html = html.replace(
    "</style>",
    """
@media print {
  .final-era-pair {
    break-before: page !important;
    page-break-before: always !important;
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }
  .final-era-pair .era-block {
    break-before: auto !important;
    page-break-before: auto !important;
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }
}
</style>""",
    1
)

p.write_text(html)
PY

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless \
  --disable-gpu \
  --print-to-pdf="$PDF" \
  --print-to-pdf-no-header \
  "file://$HTML"

open "$PDF"
