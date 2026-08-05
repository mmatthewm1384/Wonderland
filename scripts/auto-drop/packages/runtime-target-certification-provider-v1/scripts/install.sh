#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/loader.py"

cp "$TARGET" "$TARGET.runtime-target-certification-provider-v1.bak"


python3 <<PY
from pathlib import Path

p = Path("$TARGET")

text = p.read_text()

old = """and data.get("certified") is True"""

new = """and self._resolve_certification(
                    data
                )"""


if old in text:
    text = text.replace(old, new)


if "_resolve_certification" not in text:

    insert = """

    def _resolve_certification(self, data):
        if data.get("certified") is True:
            return True

        instance = data.get("instance")

        if not instance:
            return False

        cert_root = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
        )

        if not cert_root.exists():
            return False

        for artifact in cert_root.rglob("*.json"):
            try:
                payload = artifact.read_text()

                if instance in payload:
                    return True

            except Exception:
                pass

        return False

"""

    marker = "    def "

    index = text.find(marker)

    if index != -1:
        text = text[:index] + insert + text[index:]


p.write_text(text)

PY


python3 -m compileall "$TARGET"

echo "Runtime target certification provider installed"

