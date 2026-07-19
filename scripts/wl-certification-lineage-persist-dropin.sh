#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"
PKG="$ROOT/builder/python/wlplatform/wlplatform"

cat > "$PKG/certification_lineage_persist.py" <<'PY'
from __future__ import annotations

import json
from pathlib import Path

from .certification_lineage import create_lineage


CERT_ROOT = (
    "vault/08-Operations/"
    "certifications/normalized"
)


def persist_lineage(root):

    root = Path(root)

    cert_root = root / CERT_ROOT

    updated = []

    for path in sorted(
        cert_root.glob("*-certification.json")
    ):

        payload = json.loads(
            path.read_text()
        )

        engine = payload.get("engine")

        if not engine:
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

        updated.append(engine)

    return {
        "result": "PASS",
        "updated": updated,
    }
PY


python3 - <<'PY'
from pathlib import Path

path = Path(
"builder/python/wlplatform/wlplatform/cli.py"
)

text = path.read_text()

if "persist_lineage" not in text:

    marker = '''
        if getattr(
            args,
            "certify_action",
            None
        ) == "lineage":
'''

    handler = '''
        if getattr(
            args,
            "certify_action",
            None
        ) == "persist-lineage":

            from .certification_lineage_persist import (
                persist_lineage,
            )

            report = persist_lineage(
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

    text = text.replace(
        marker,
        handler + marker
    )


if '"persist-lineage"' not in text:

    text = text.replace(
        '''
    certify_sub.add_parser(
        "lineage"
    )
''',
        '''
    certify_sub.add_parser(
        "persist-lineage"
    )

    certify_sub.add_parser(
        "lineage"
    )
'''
    )

path.write_text(text)

PY


python3 -m py_compile \
"$PKG/certification_lineage_persist.py" \
"$PKG/cli.py"

echo "lineage persistence drop-in complete"
