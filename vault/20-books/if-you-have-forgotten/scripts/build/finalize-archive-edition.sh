#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSS="$ROOT/build/theme/wonderland-archive.css"
COVER="$ROOT/manuscript/00-cover.md"

echo "[*] Finalizing Wonderland Archive Edition"

cp "$CSS" "$CSS.bak.$(date +%Y%m%d-%H%M%S)"
cp "$COVER" "$COVER.bak.$(date +%Y%m%d-%H%M%S)"

python3 - <<'PY'
from pathlib import Path
import re

root = Path.cwd()
css = root / "build/theme/wonderland-archive.css"
cover = root / "manuscript/00-cover.md"

s = css.read_text()

s = re.sub(
    r"h1\s*\{[^}]*\}",
    """h1 {
  color: #EAEAEA;
  font-size: 2.1rem;
  letter-spacing: 0.04em;
  margin-top: 4rem;
  margin-bottom: 1.6rem;
}

h1:first-of-type {
  color: var(--wl-cyan);
}""",
    s,
    count=1,
    flags=re.S,
)

s = s.replace(
    "border: 1px solid rgba(0, 229, 255, 0.28);",
    "border: 1px solid rgba(0, 229, 255, 0.40);",
)

if "word-spacing:" not in s:
    s = s.replace(
        "line-height: 1.55;",
        "line-height: 1.55;\n  letter-spacing: .01em;\n  word-spacing: .02em;",
        1,
    )

css.write_text(s)

c = cover.read_text()

banner = """Wonderland Archive

Identity Recovery Series

Document 01

***

"""

if not c.startswith("Wonderland Archive"):
    c = banner + c

cover.write_text(c)

print("[ok] archive CSS and cover finalized")
PY

"$ROOT/scripts/build/build-book.sh"

pandoc \
  "$ROOT/build/manuscript.md" \
  -s \
  --embed-resources \
  --standalone \
  --css "$CSS" \
  -o "$ROOT/build/html/if-you-have-forgotten-wonderland-archive.html"

echo "[ok] archive html built"
echo "$ROOT/build/html/if-you-have-forgotten-wonderland-archive.html"

open -a Safari "$ROOT/build/html/if-you-have-forgotten-wonderland-archive.html"
