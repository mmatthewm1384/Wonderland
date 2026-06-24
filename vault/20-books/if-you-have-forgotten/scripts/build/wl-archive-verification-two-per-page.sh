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

start = html.find('<h1 id="identity-recovery-verification">')
if start == -1:
    raise SystemExit("Missing identity recovery verification section")

end = html.find("</body>", start)
section = html[start:end]

# Split section into h1 opener + h2 blocks.
h2_re = re.compile(
    r'(<h2 id="[^"]+">.*?</h2>.*?)(?=<h2 id="[^"]+">|</body>)',
    re.S
)

blocks = h2_re.findall(section)
if not blocks:
    raise SystemExit("No h2 blocks found in verification section")

# Remove h2 blocks from section once.
section_without_blocks = h2_re.sub("__VERIFY_BLOCK__", section, count=len(blocks))
section_without_blocks = section_without_blocks.replace("__VERIFY_BLOCK__", "", 1)
section_without_blocks = section_without_blocks.replace("__VERIFY_BLOCK__", "")

first = blocks[0]
rest = blocks[1:]

pairs = []
for i in range(0, len(rest), 2):
    pair_blocks = rest[i:i+2]
    pairs.append(
        '<section class="verification-pair">\n'
        + "\n".join(f'<section class="verification-block">\n{b}\n</section>' for b in pair_blocks)
        + '\n</section>'
    )

new_section = section_without_blocks + "\n" + first + "\n" + "\n".join(pairs)

html = html[:start] + new_section + html[end:]

css = """
@media print {
  .verification-pair {
    break-before: page !important;
    page-break-before: always !important;
    break-inside: avoid !important;
    page-break-inside: avoid !important;
  }

  .verification-block {
    break-inside: avoid !important;
    page-break-inside: avoid !important;
    margin-bottom: 2rem !important;
  }

  .verification-block h2,
  .verification-block h3,
  .verification-block h4 {
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

echo "[ok] verification section grouped two per page"
