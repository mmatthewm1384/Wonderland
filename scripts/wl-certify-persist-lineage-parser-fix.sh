#!/usr/bin/env bash
set -euo pipefail

FILE="builder/python/wlplatform/wlplatform/cli.py"

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/cli.py"
)

text = path.read_text()

needle = '''
    certify_sub.add_parser(
        "lineage"
    )
'''

insert = '''
    certify_sub.add_parser(
        "persist-lineage"
    )

'''

if '"persist-lineage"' not in text:

    if needle not in text:
        raise SystemExit(
            "lineage parser block not found"
        )

    text = text.replace(
        needle,
        insert + needle,
        1,
    )

    path.write_text(text)

    print(
        "added certify persist-lineage parser"
    )

else:
    print(
        "persist-lineage already exists"
    )
PY


python3 -m py_compile "$FILE"

echo "parser fix complete"
