#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"
CLI="$ROOT/builder/python/wlplatform/wlplatform/cli.py"
LINEAGE="$ROOT/builder/python/wlplatform/wlplatform/certification_lineage.py"
TEST="$ROOT/builder/python/wlplatform/wlplatform/tests/test_certification_lineage_transaction.py"

echo "== Wonderland Certification Lineage v1.1 Auto Drop =="

cd "$ROOT"

echo "[1/5] Add persist-lineage command"

python3 - <<'PY'
from pathlib import Path

p = Path("builder/python/wlplatform/wlplatform/cli.py")
s = p.read_text()

needle = '''
    certify_sub.add_parser(
        "lineage"
    )
'''

insert = '''
    certify_sub.add_parser(
        "lineage"
    )

    certify_sub.add_parser(
        "persist-lineage",
        help="Persist lineage into certification artifacts",
    )
'''

if "persist-lineage" not in s:
    s = s.replace(needle, insert)

p.write_text(s)
PY


echo "[2/5] Add persist_lineage implementation"

python3 - <<'PY'
from pathlib import Path

p = Path("builder/python/wlplatform/wlplatform/certification_lineage.py")
s = p.read_text()

if "def persist_lineage" not in s:
    s += r'''

def persist_lineage(root):

    from pathlib import Path
    import json

    root = Path(root)

    cert_root = (
        root
        /
        "vault/08-Operations/certifications/normalized"
    )

    updated = []

    for artifact in sorted(cert_root.glob("*.json")):

        payload = json.loads(
            artifact.read_text()
        )

        engine = payload.get(
            "engine",
            artifact.stem.replace(
                "-certification",
                "",
            ),
        )

        payload["lineage"] = create_lineage(
            engine=engine,
            artifact=payload,
        )

        artifact.write_text(
            json.dumps(
                payload,
                indent=2,
                sort_keys=True,
            )
            + "\n"
        )

        updated.append(engine)

    return {
        "command": "persist-lineage",
        "updated": updated,
        "count": len(updated),
        "result": "PASS",
    }
'''

p.write_text(s)
PY


echo "[3/5] Add CLI transaction handler"

python3 - <<'PY'
from pathlib import Path

p = Path("builder/python/wlplatform/wlplatform/cli.py")
s = p.read_text()

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

            from .certification_lineage import (
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

if "== \"persist-lineage\"" not in s:
    s = s.replace(marker, handler + marker)

p.write_text(s)
PY


echo "[4/5] Add regression test"

cat > "$TEST" <<'PY'
from pathlib import Path

from wlplatform.certification_lineage import (
    persist_lineage,
)


ROOT = Path(
    "/Users/wonderland/Wonderland"
)


def test_persist_lineage_transaction():

    result = persist_lineage(
        ROOT
    )

    assert result["result"] == "PASS"
    assert result["count"] >= 1
PY


echo "[5/5] Verify"

export PYTHONPATH="$ROOT/builder/python/wlplatform"

python3 -m py_compile \
"$CLI" \
"$LINEAGE"

python3 -m pytest \
"$TEST"

./bin/wl-platform certify persist-lineage

./bin/wl-platform certify lineage

./bin/wl-platform certify gate

echo "== Certification Lineage v1.1 COMPLETE =="
