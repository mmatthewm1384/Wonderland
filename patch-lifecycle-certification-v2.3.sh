#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_HOME:-$HOME/Wonderland}"
ENGINE="$ROOT/builder/python/wlruntime/wlruntime/engine.py"

[[ -f "$ENGINE" ]] || {
  echo "Missing engine.py: $ENGINE"
  exit 1
}

echo "Creating backup..."
cp "$ENGINE" "$ENGINE.bak.$(date +%Y%m%dT%H%M%SZ)"

python3 - "$ENGINE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

if "_recover_stale_operation" in text:
    print("Already patched")
    raise SystemExit(0)

needle = "    def start("

if needle not in text:
    raise SystemExit("start marker missing")

method = r'''
    def _recover_stale_operation(self) -> None:
        """
        Recover stale lifecycle operations after interrupted execution.

        Certification and runtime commands must never inherit a half-written
        lifecycle transaction. This clears transient operation metadata while
        preserving the last known runtime state.
        """

        state = self.state_store.read()

        operation = state.get("operation")
        operation_id = state.get("operation_id")

        if operation is None and operation_id is None:
            return

        status = state.get("status")

        if status not in {
            "starting",
            "stopping",
            "failed",
        }:
            return

        state["operation"] = None
        state["operation_id"] = None

        if status in {
            "starting",
            "stopping",
            "failed",
        }:
            state["status"] = (
                "stopped"
                if not state.get("started_engines")
                else "running"
            )

        state["last_error"] = None

        self.state_store.write(state)

'''

text = text.replace(
    needle,
    method + needle,
    1,
)

path.write_text(text)

print("Inserted _recover_stale_operation")
PY

python3 -m compileall \
  "$ROOT/builder/python/wlruntime/wlruntime"

echo
echo "Lifecycle Certification v2.3 patch complete."
echo
echo "Next:"
echo
echo "PYTHONPATH=builder/python/wlruntime \\"
echo "python3 -m wlruntime.cli --root ~/Wonderland status"
echo
echo "wl runtime certify --mode full"
