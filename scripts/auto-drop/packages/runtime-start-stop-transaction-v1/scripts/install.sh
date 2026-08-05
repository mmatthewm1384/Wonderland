#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

SERVICE="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

python3 - "$SERVICE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()

marker = "    def _event(self, action, result):"

if "_transaction_event" in text:
    print("transaction already installed")
    raise SystemExit(0)

insert = '''
    def _transaction_event(
        self,
        action,
        result
    ):

        import json
        from datetime import datetime, timezone

        event = {
            "service": "runtime",
            "transaction": True,
            "action": action,
            "result": result,
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat()
        }

        ledger = (
            self.root
            / "runtime"
            / "events"
            / "runtime-transactions.jsonl"
        )

        ledger.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        with ledger.open("a") as f:
            f.write(
                json.dumps(event)
                + "\\\\n"
            )

        return event

'''

text = text.replace(
    marker,
    insert + marker
)

path.write_text(text)

print("transaction binding installed")
PY

echo "installed"
