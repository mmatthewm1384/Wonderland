#!/usr/bin/env bash
set -euo pipefail


echo "== Registry Engine v1.3 Verification =="


cd "$(dirname "$0")/../.."


export PYTHONPATH="$PWD/builder/python/wlplatform:$PYTHONPATH"


python3 - <<'PY'

from pathlib import Path

from wlplatform.engines import get_engine


engine = get_engine(
    "registry",
    Path.cwd()
)


verify = engine.verify()

print(
    verify.to_dict()
)


assert (
    verify.status
    ==
    "PASS"
)


cert = engine.certify()


print(
    cert.to_dict()
)


assert (
    cert.status
    ==
    "PASS"
)


print(
    "Registry v1.3 PASS"
)

PY
