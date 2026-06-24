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

# Wrap LAST PAGE through END OF DOCUMENT only.
pattern = re.compile(
    r'(<h2 id="last-page">LAST PAGE</h2>.*?<p>END OF DOCUMENT</p>)',
    re.S
)

html, count = pattern.subn(
    r'<section class="last-page-block">\n\1\n</section>',
    html,
    count=1
)

if count != 1:
    raise SystemExit("[-] Could not find LAST PAGE block")

css = """
@media print {
  .last-page-block {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  .last-page-block h2,
  .last-page-block p,
  .last-page-block hr {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  .last-page-block h2 {
    break-after: avoid !important;
    page-break-after: avoid !important;
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

echo "[ok] LAST PAGE block kept together"
