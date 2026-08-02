#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:?WL_ROOT is required}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima.py"
BACKUP="${TARGET}.before-idempotent-start"

echo "LIMA IDEMPOTENT START PATCH"
echo "TARGET: $TARGET"

if [[ ! -f "$TARGET" ]]; then
    echo "ERROR: target missing"
    exit 1
fi

if [[ ! -f "$BACKUP" ]]; then
    cp "$TARGET" "$BACKUP"
    echo "BACKUP CREATED"
fi

python3 - "$TARGET" <<'PY'
from pathlib import Path
import sys

target = Path(sys.argv[1])
text = target.read_text()

marker = 'reason": "already_running"'

if marker in text:
    print("PATCH ALREADY PRESENT")
    raise SystemExit(0)

start = text.find("    def start(self):")
stop = text.find("    def stop(self):")

if start == -1 or stop == -1:
    raise SystemExit("Unable to locate start/stop methods")

replacement = '''    def start(self):

        state = self._run(
            [
                "limactl",
                "list",
                "--format",
                "{{.Status}}",
                self.instance
            ]
        )

        if state["exit_code"] == 0 and state["stdout"].strip() == "Running":
            return {
                "adapter": "lima",
                "instance": self.instance,
                "action": "skipped",
                "reason": "already_running",
                "state": "Running"
            }

        return self._run(
            [
                "limactl",
                "start",
                self.instance
            ]
        )

'''

target.write_text(
    text[:start] +
    replacement +
    text[stop:]
)

print("PATCH APPLIED")
PY

echo "INSTALL PASS"
