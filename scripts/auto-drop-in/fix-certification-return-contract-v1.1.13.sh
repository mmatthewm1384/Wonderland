#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

python3 - <<'PY'
from pathlib import Path

root = Path.cwd()

cert = (
    root /
    "builder/python/wlplatform/wlplatform/certification/certifier.py"
)

text = cert.read_text()


# Ensure return contract
old = """
    return _certify_platform(root)
"""

new = """
    result = _certify_platform(root)

    artifact = (
        root
        / "vault"
        / "08-Operations"
        / "certifications"
        / "platform-certification.json"
    )

    result["artifact"] = str(artifact)

    return result
"""

text = text.replace(
    old,
    new,
    1,
)


# normalize error import
text = text.replace(
    "from .errors import CertificationError\n",
    ""
)

text = text.replace(
    "from .adapters.registry import adapters",
    "from .adapters.registry import adapters\nfrom .errors import CertificationError",
)

cert.write_text(text)


# Fix public export identity
init = (
    root /
    "builder/python/wlplatform/wlplatform/certification/__init__.py"
)

text = init.read_text()

# remove duplicate local import
text = text.replace(
    "from .errors import CertificationError\n",
    "",
)

# add after imports
if "from .errors import CertificationError" not in text:
    text = (
        text
        + "\nfrom .errors import CertificationError\n"
    )

init.write_text(text)

print("patched")
PY

echo PASS
