#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"

python3 - <<'PY'
from pathlib import Path
import re

css = Path("build/theme/wonderland-archive.css")
s = css.read_text()

# Remove h1:first-of-type block if present
s = re.sub(r'\n*h1:first-of-type\s*\{[^}]*\}\s*', '\n', s, flags=re.S)

# Force the main h1 block to use wl-cyan
s = re.sub(
    r'h1\s*\{[^}]*\}',
    '''h1 {
  color: var(--wl-cyan);
  font-size: 2.1rem;
  letter-spacing: 0.04em;
  margin-top: 4rem;
  margin-bottom: 1.6rem;
}''',
    s,
    count=1,
    flags=re.S
)

css.write_text(s)
print("[ok] h1 restored to wl-cyan")
PY

"$ROOT/scripts/build/build-book.sh"

pandoc \
  "$ROOT/build/manuscript.md" \
  -s \
  --embed-resources \
  --standalone \
  --css "$CSS" \
  -o "$ROOT/build/html/if-you-have-forgotten-wonderland-archive.html"

open -a Safari "$ROOT/build/html/if-you-have-forgotten-wonderland-archive.html"

echo "[ok] archive rebuilt with cyan H1 headings"
