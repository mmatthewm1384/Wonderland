#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$ROOT"

STAMP="$(date +%Y%m%d-%H%M%S)"

backup() {
    local file="$1"
    cp "$file" "$file.bak.v2.$STAMP"
}

restore_latest_v1() {
    local file="$1"
    local backup

    backup=$(ls -1t "$file".bak.* 2>/dev/null | head -1 || true)

    if [[ -n "$backup" ]]; then
        cp "$backup" "$file"
        echo "Restored $file from $backup"
    fi
}

FILES=(
builder/python/wlruntime/wlruntime/engine.py
builder/python/wlruntime/wlruntime/cli.py
builder/python/wlruntime/wlruntime/state.py
builder/python/wlruntime/wlruntime/regression.py
)

echo "Restoring v1 backups if needed..."

for file in "${FILES[@]}"; do
    restore_latest_v1 "$file"
done


echo "Creating v2 backups..."

for file in "${FILES[@]}"; do
    backup "$file"
done


python3 <<'PY'
from pathlib import Path

root = Path("/Users/wonderland/Wonderland")


# --------------------------------------------------
# state.py
# --------------------------------------------------

path = root / "builder/python/wlruntime/wlruntime/state.py"
text = path.read_text()

if '"lifecycle": {' not in text:
    text = text.replace(
'''            "rollback": {
                "attempted": False,
                "completed": False,
                "results": [],
            },
''',
'''            "rollback": {
                "attempted": False,
                "completed": False,
                "results": [],
            },
            "lifecycle": {
                "last_transition": None,
                "sleep_timestamp": None,
            },
'''
    )

path.write_text(text)


# --------------------------------------------------
# cli.py
# --------------------------------------------------

path = root / "builder/python/wlruntime/wlruntime/cli.py"
text = path.read_text()

text = text.replace(
'''    for name in ("start", "stop"):
''',
'''    for name in (
        "start",
        "stop",
        "restart",
        "sleep",
        "wake",
    ):
'''
)

if "def cmd_restart" in text:
    start = text.index("def cmd_restart")
    end = text.index("def main")
    text = text[:start] + text[end:]

text = text.replace(
'''        elif arguments.command == "stop":
            result = engine.stop(
                dry_run=arguments.dry_run
            )

        else:
''',
'''        elif arguments.command == "stop":
            result = engine.stop(
                dry_run=arguments.dry_run
            )

        elif arguments.command == "restart":
            result = engine.restart(
                dry_run=arguments.dry_run
            )

        elif arguments.command == "sleep":
            result = engine.sleep(
                dry_run=arguments.dry_run
            )

        elif arguments.command == "wake":
            result = engine.wake(
                dry_run=arguments.dry_run
            )

        else:
'''
)

path.write_text(text)


# --------------------------------------------------
# engine.py
# --------------------------------------------------

path = root / "builder/python/wlruntime/wlruntime/engine.py"
text = path.read_text()


# rename existing start/stop implementations
text = text.replace(
'''    def start(self, *, dry_run: bool = False) -> dict[str, Any]:
''',
'''    def _start_locked(self, *, dry_run: bool = False) -> dict[str, Any]:
''',
1,
)

text = text.replace(
'''    def stop(self, *, dry_run: bool = False) -> dict[str, Any]:
''',
'''    def _stop_locked(self, *, dry_run: bool = False) -> dict[str, Any]:
''',
1,
)


# Insert public wrappers before _start_locked

anchor = "    def _start_locked(self, *, dry_run: bool = False) -> dict[str, Any]:"

wrappers = '''
    def start(self, *, dry_run: bool = False) -> dict[str, Any]:
        with self.state_store.lock():
            return self._start_locked(
                dry_run=dry_run
            )


    def stop(self, *, dry_run: bool = False) -> dict[str, Any]:
        with self.state_store.lock():
            return self._stop_locked(
                dry_run=dry_run
            )


'''

text = text.replace(anchor, wrappers + anchor)


# Add lifecycle methods before verify

marker = "    def verify(self) -> dict[str, Any]:"

methods = '''

    def restart(self, *, dry_run: bool = False) -> dict[str, Any]:
        if dry_run:
            return {
                "result": "PASS",
                "action": "restart",
                "stop": self.plan("stop"),
                "start": self.plan("start"),
            }

        with self.state_store.lock():
            stopped = self._stop_locked()
            started = self._start_locked()
            health = self.health()

            return {
                "result": (
                    "PASS"
                    if health["result"] == "PASS"
                    else "FAIL"
                ),
                "action": "restart",
                "stop": stopped,
                "start": started,
                "health": health,
            }


    def sleep(self, *, dry_run: bool = False) -> dict[str, Any]:
        if dry_run:
            return self.plan("stop")

        with self.state_store.lock():
            stopped = self._stop_locked()

            state = self.state_store.read()
            state["lifecycle"] = {
                "last_transition": "sleep",
                "sleep_timestamp": utc_now(),
            }
            self.state_store.write(state)

            return {
                "result": "PASS",
                "action": "sleep",
                "stop": stopped,
                "state": state,
            }


    def wake(self, *, dry_run: bool = False) -> dict[str, Any]:
        if dry_run:
            return self.plan("start")

        with self.state_store.lock():
            started = self._start_locked()

            state = self.state_store.read()
            state["lifecycle"] = {
                "last_transition": "wake",
                "sleep_timestamp": None,
            }
            self.state_store.write(state)

            health = self.health()

            return {
                "result": (
                    "PASS"
                    if health["result"] == "PASS"
                    else "FAIL"
                ),
                "action": "wake",
                "start": started,
                "health": health,
                "state": state,
            }


'''

text = text.replace(marker, methods + marker)

path.write_text(text)


print("Lifecycle Patch v2 applied.")
PY


echo "Compile validation..."

python3 -m compileall \
builder/python/wlruntime/wlruntime


echo "Regression validation..."

PYTHONPATH=builder/python/wlruntime \
python3 -m wlruntime.cli \
--root "$ROOT" \
self-test


echo "Lifecycle Patch v2 complete."
