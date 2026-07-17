#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

echo "== Wonderland Verify Registry Adapter =="

grep -R "engines" \
"$ROOT/builder/python/wlplatform" \
-n > /tmp/wl-verify-engine-refs.txt || true

cat /tmp/wl-verify-engine-refs.txt


python3 <<'PY'

from pathlib import Path

root = Path("/Users/wonderland/Wonderland")

targets = [
    root / "builder/python/wlplatform",
]

old = "certifications/engines"
new = "certifications/normalized"


changed=[]

for base in targets:
    for path in base.rglob("*.py"):

        text = path.read_text()

        if old in text:
            backup = path.with_suffix(
                path.suffix + ".backup"
            )

            if not backup.exists():
                backup.write_text(text)

            text=text.replace(old,new)

            path.write_text(text)

            changed.append(str(path))


print()
print("UPDATED:")
for item in changed:
    print(item)

PY


echo
echo "== Verify =="

./bin/wl-platform verify
