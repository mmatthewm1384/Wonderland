#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"
PKG="$ROOT/builder/python/wlplatform/wlplatform"

echo "== Wonderland Certification Migration Drop-In =="

cat > "$PKG/certification_migrate.py" <<'PY'
from __future__ import annotations

import json
from pathlib import Path

from .certification_lineage import create_lineage


CERT_ROOT = (
    "vault/08-Operations/"
    "certifications/normalized"
)


def migrate_certifications(root):

    root = Path(root)

    cert_root = (
        root / CERT_ROOT
    )

    migrated = []

    for path in sorted(
        cert_root.glob("*-certification.json")
    ):

        payload = json.loads(
            path.read_text()
        )

        engine = payload.get("engine")

        if not engine:
            continue

        if "lineage" in payload:
            migrated.append(
                {
                    "engine": engine,
                    "status": "SKIP",
                }
            )
            continue

        lineage = create_lineage(
            engine=engine,
            artifact=payload,
        )

        payload["lineage"] = lineage

        path.write_text(
            json.dumps(
                payload,
                indent=2,
            )
            + "\n"
        )

        migrated.append(
            {
                "engine": engine,
                "status": "MIGRATED",
            }
        )

    return {
        "result": "PASS",
        "migrated": migrated,
    }
PY


python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/cli.py"
)

text = path.read_text()

marker = '''
    certify_sub.add_parser(
        "lineage"
    )
'''

if 'certify_sub.add_parser(\n        "migrate"\n    )' not in text:
    text = text.replace(
        marker,
        '''
    certify_sub.add_parser(
        "migrate"
    )

''' + marker
    )

handler = '''
        if getattr(
            args,
            "certify_action",
            None
        ) == "migrate":

            from .certification_migrate import (
                migrate_certifications,
            )

            report = migrate_certifications(
                root
            )

            print(
                json.dumps(
                    report,
                    indent=2,
                    sort_keys=True,
                )
            )

            return

'''

anchor = '''
        if getattr(
            args,
            "certify_action",
            None
        ) == "lineage":
'''

if "migrate_certifications" not in text:
    text = text.replace(
        anchor,
        handler + anchor
    )

path.write_text(text)

print("patched certification migration")
PY


python3 -m py_compile \
"$PKG/certification_migrate.py" \
"$PKG/cli.py"

echo
echo "Migration available:"
echo "./bin/wl-platform certify migrate"
