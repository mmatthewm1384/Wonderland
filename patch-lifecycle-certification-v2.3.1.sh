#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME/Wonderland"
ENGINE="$ROOT/builder/python/wlruntime/wlruntime/engine.py"

echo "Backing up engine..."
cp "$ENGINE" "$ENGINE.bak.$(date +%Y%m%dT%H%M%SZ)"

python3 - "$ENGINE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

if "def _recover_stale_operation" in text:
    print("Method already exists")
    raise SystemExit(0)

# Find the RuntimeEngine class boundary
class_marker = "class RuntimeEngine"

if class_marker not in text:
    raise SystemExit("RuntimeEngine class missing")

class_pos = text.index(class_marker)

# Find first method after class
method_marker = "    def "

method_pos = text.find(method_marker, class_pos)

if method_pos == -1:
    raise SystemExit("RuntimeEngine method insertion point missing")

method = '''
    def _recover_stale_operation(self) -> None:
        """
        Recover interrupted lifecycle transactions.

        Certification requires deterministic lifecycle state.
        Any stale operation marker from an interrupted start/stop
        transaction is cleared before execution continues.
        """

        state = self.state_store.read()

        operation = state.get("operation")
        operation_id = state.get("operation_id")

        if operation is None and operation_id is None:
            return

        started = state.get("started_engines") or []

        state["operation"] = None
        state["operation_id"] = None

        if started:
            state["status"] = "running"
        else:
            state["status"] = "stopped"

        state["last_error"] = None

        self.state_store.write(state)

'''

text = text[:method_pos] + method + text[method_pos:]

path.write_text(text)

print("Inserted _recover_stale_operation into RuntimeEngine")
PY

python3 -m compileall \
"$ROOT/builder/python/wlruntime/wlruntime"

PYTHONPATH="$ROOT/builder/python/wlruntime" \
python3 - <<'PY'
from wlruntime.engine import RuntimeEngine
print("recover method:", hasattr(RuntimeEngine, "_recover_stale_operation"))
PY

echo "Patch complete"
