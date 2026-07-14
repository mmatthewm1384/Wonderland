#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

WL="bin/wl"

echo "Adding wl doctor command..."

python3 <<'PY'
from pathlib import Path

path = Path("bin/wl")

text = path.read_text()

if "wldoctor" not in text:
    marker = "case \"${1:-}\" in\n"

    insert = '''doctor)
    shift

    PYTHONPATH="builder/python/wldoctor:builder/python/wlrepository" \\
    python -m wldoctor.cli "$@"

    exit $?
    ;;

'''

    if marker not in text:
        raise SystemExit(
            "bin/wl case block not found"
        )

    text = text.replace(
        marker,
        marker + insert,
    )

path.write_text(text)

PY

chmod +x "$WL"

echo
echo "Testing wl doctor..."

./bin/wl doctor --json

echo
echo "wl doctor integration complete."
