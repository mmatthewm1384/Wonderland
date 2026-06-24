#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Wonderland/vault/20-books/if-you-have-forgotten"
HTML="$ROOT/build/html/if-you-have-forgotten-wonderland-archive-final.html"
PDF="$ROOT/build/pdf/if-you-have-forgotten-wonderland-archive-final.pdf"

cd "$ROOT"

cp "$HTML" "$HTML.bak.$(date +%Y%m%d-%H%M%S)"

python3 <<'PY'
from pathlib import Path
import re

p = Path("build/html/if-you-have-forgotten-wonderland-archive-final.html")
html = p.read_text()

# Wrap final verification H2 sections so Chrome will not split each block.
ids = [
    "foundational-findings",
    "character-findings",
    "adversity-findings",
    "relationship-findings",
    "creative-findings",
    "identity-findings",
    "enduring-qualities",
    "recovery-questions",
    "final-determination",
    "verification-summary",
    "final-result",
]

for id_ in ids:
    pattern = re.compile(
        rf'(<h2 id="{re.escape(id_)}">.*?</h2>.*?)(?=<h2 id="|<h1 id=|</body>)',
        re.S
    )
    html = pattern.sub(
        rf'<section class="keep-final-block">\n\1\n</section>',
        html,
        count=1
    )

css = """
@media print {
  .keep-final-block {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  .keep-final-block h2,
  .keep-final-block h3,
  .keep-final-block h4 {
    break-after: avoid !important;
    page-break-after: avoid !important;
  }

  .keep-final-block p {
    orphans: 4 !important;
    widows: 4 !important;
  }
}
"""

html = html.replace("</style>", css + "\n</style>", 1)
p.write_text(html)
PY

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless \
  --disable-gpu \
  --print-to-pdf="$PDF" \
  --print-to-pdf-no-header \
  "file://$HTML"

open "$PDF"

echo "[ok] final text blocks protected"
