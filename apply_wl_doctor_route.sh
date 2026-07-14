#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

WL="bin/wl"

echo "Adding WL Doctor public route..."

python3 <<'PY'
from pathlib import Path

path = Path("bin/wl")

text = path.read_text()

if "BEGIN WL-DOCTOR-PUBLIC-ROUTE" in text:
    print("Doctor route already exists")
    raise SystemExit(0)

marker = "# BEGIN WL-RUNTIME-PUBLIC-ROUTES\n"

block = r'''# BEGIN WL-DOCTOR-PUBLIC-ROUTE
# Stable public route into the Wonderland Doctor Engine.
#
#   wl doctor
#   wl doctor --json
if [[ "${1:-}" == "doctor" ]]; then
  shift

  _wl_doctor_root="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &&
    pwd -P
  )"

  _wl_doctor_base="${WL_ROOT:-$_wl_doctor_root}"

  if [[ ! -d "$_wl_doctor_base/builder/python/wldoctor" ]]; then
    printf 'FAIL Doctor Engine unavailable: %s\n' \
      "$_wl_doctor_base/builder/python/wldoctor" >&2
    exit 1
  fi

  PYTHONPATH="$_wl_doctor_base/builder/python/wldoctor:$_wl_doctor_base/builder/python/wlrepository${PYTHONPATH:+:$PYTHONPATH}" \
    python -m wldoctor.cli "$@"

  exit $?
fi
# END WL-DOCTOR-PUBLIC-ROUTE

'''

if marker not in text:
    raise SystemExit(
        "runtime route marker missing"
    )

text = text.replace(
    marker,
    block + marker,
    1,
)

path.write_text(text)

PY

chmod +x "$WL"

echo
echo "Testing wl doctor..."

./bin/wl doctor --json
