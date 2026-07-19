#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

python3 - <<'PY'
from pathlib import Path

root = Path.cwd()

init = (
    root /
    "builder/python/wlplatform/wlplatform/certification/__init__.py"
)

text = init.read_text()

# Remove all CertificationError imports
lines = [
    line
    for line in text.splitlines()
    if "CertificationError" not in line
]

text = "\n".join(lines) + "\n"

# Add canonical import at top after module docstring/imports
text = (
    "from .errors import CertificationError\n\n"
    + text
)

init.write_text(text)


certifier = (
    root /
    "builder/python/wlplatform/wlplatform/certification/certifier.py"
)

text = certifier.read_text()

# Ensure certifier imports the exact same class
if "from .errors import CertificationError" not in text:
    text = text.replace(
        "from .adapters.registry import adapters",
        "from .adapters.registry import adapters\nfrom .errors import CertificationError",
    )

certifier.write_text(text)

print("patched CertificationError identity")
PY

echo PASS
