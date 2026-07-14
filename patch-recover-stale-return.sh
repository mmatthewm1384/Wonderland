#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_HOME:-$HOME/Wonderland}"
cd "$ROOT"

TARGET="builder/python/wlruntime/wlruntime/engine.py"

echo "Backing up engine..."
cp "$TARGET" "${TARGET}.bak.$(date +%Y%m%d%H%M%S)"

python3 - <<'PY'
from pathlib import Path

path = Path("builder/python/wlruntime/wlruntime/engine.py")
text = path.read_text()

start = text.find("    def _recover_stale_operation")
end = text.find("    def __init__", start)

if start == -1 or end == -1:
    raise SystemExit("recover method boundaries not found")

new_method = '''    def _recover_stale_operation(
        self,
        state: dict | None = None,
    ) -> dict:
        """
        Recover interrupted lifecycle operations.

        Contract:
        - Always return a valid state dictionary.
        - Never mutate lifecycle flow by returning None.
        """

        if state is None:
            state = self.state_store.read()

        if state.get("operation") in {
            "start",
            "stop",
        }:
            status = state.get("status")

            if status in {
                "starting",
                "stopping",
                "rolling-back",
            }:
                state["status"] = "stopped"
                state["operation"] = None
                state["operation_id"] = None
                state["started_engines"] = []

                state["rollback"]["attempted"] = False
                state["rollback"]["completed"] = False

                self.state_store.write(state)

        return state


'''

text = text[:start] + new_method + text[end:]

path.write_text(text)

print("patched _recover_stale_operation")
PY

python3 -m compileall builder/python/wlruntime/wlruntime

echo
echo "PASS"
