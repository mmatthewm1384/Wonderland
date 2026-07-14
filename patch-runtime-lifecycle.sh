#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$ROOT"

STAMP="$(date +%Y%m%d-%H%M%S)"

FILES=(
  "builder/python/wlruntime/wlruntime/cli.py"
  "builder/python/wlruntime/wlruntime/engine.py"
  "builder/python/wlruntime/wlruntime/state.py"
  "builder/python/wlruntime/wlruntime/regression.py"
)

echo "Creating backups..."

for file in "${FILES[@]}"; do
    cp "$file" "$file.bak.$STAMP"
done

echo "Applying lifecycle patch..."

python3 <<'PY'
from pathlib import Path

root = Path("/Users/wonderland/Wonderland")


# --------------------------------------------------
# state.py
# --------------------------------------------------

path = root / "builder/python/wlruntime/wlruntime/state.py"
text = path.read_text()

old = '''            "rollback": {
                "attempted": False,
                "completed": False,
                "results": [],
            },
            "last_error": None,
'''

new = '''            "rollback": {
                "attempted": False,
                "completed": False,
                "results": [],
            },
            "lifecycle": {
                "last_transition": None,
                "sleep_timestamp": None,
            },
            "last_error": None,
'''

if old not in text:
    raise SystemExit("state.py anchor missing")

text = text.replace(old, new)

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


start = text.index(
'''def cmd_restart(args):
'''
)

end = text.index(
'''def main(''',
    start
)

text = text[:start] + text[end:]


old = '''        elif arguments.command == "stop":
            result = engine.stop(
                dry_run=arguments.dry_run
            )

        else:
'''

new = '''        elif arguments.command == "stop":
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

if old not in text:
    raise SystemExit("cli routing anchor missing")

text = text.replace(old, new)

path.write_text(text)


# --------------------------------------------------
# engine.py
# --------------------------------------------------

path = root / "builder/python/wlruntime/wlruntime/engine.py"
text = path.read_text()


marker = '''
    def verify(self) -> dict[str, Any]:
'''


methods = r'''

    def restart(
        self,
        *,
        dry_run: bool = False,
    ) -> dict[str, Any]:
        if dry_run:
            return {
                "result": "PASS",
                "action": "restart",
                "stop": self.plan("stop"),
                "start": self.plan("start"),
            }

        with self.state_store.lock():
            stop_result = self.stop()
            start_result = self.start()

            health = self.health()

            return {
                "result": (
                    "PASS"
                    if health["result"] == "PASS"
                    else "FAIL"
                ),
                "action": "restart",
                "stop": stop_result,
                "start": start_result,
                "health": health,
            }


    def sleep(
        self,
        *,
        dry_run: bool = False,
    ) -> dict[str, Any]:
        if dry_run:
            return self.plan("stop")

        result = self.stop()

        with self.state_store.lock():
            state = self.state_store.read()
            state["lifecycle"] = {
                "last_transition": "sleep",
                "sleep_timestamp": utc_now(),
            }
            self.state_store.write(state)

        return {
            "result": "PASS",
            "action": "sleep",
            "state": state,
            "stop": result,
        }


    def wake(
        self,
        *,
        dry_run: bool = False,
    ) -> dict[str, Any]:
        if dry_run:
            return self.plan("start")

        result = self.start()
        health = self.health()

        with self.state_store.lock():
            state = self.state_store.read()
            state["lifecycle"] = {
                "last_transition": "wake",
                "sleep_timestamp": None,
            }
            self.state_store.write(state)

        return {
            "result": (
                "PASS"
                if health["result"] == "PASS"
                else "FAIL"
            ),
            "action": "wake",
            "state": state,
            "start": result,
            "health": health,
        }

'''

if marker not in text:
    raise SystemExit("engine anchor missing")

text = text.replace(marker, methods + marker)

path.write_text(text)


# --------------------------------------------------
# regression.py
# --------------------------------------------------

path = root / "builder/python/wlruntime/wlruntime/regression.py"
text = path.read_text()

anchor = '''
    def test_structural_verify_does_not_execute_health(self) -> None:
'''

tests = r'''

    def test_restart_restores_running_state(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)

            _, store, engine = self.build_engine(
                root,
                {"alpha": noop_engine()},
            )

            engine.start()
            result = engine.restart()

            self.assertEqual(
                result["result"],
                "PASS",
            )

            self.assertEqual(
                store.read()["status"],
                "running",
            )


    def test_sleep_records_transition(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)

            _, store, engine = self.build_engine(
                root,
                {"alpha": noop_engine()},
            )

            engine.start()
            result = engine.sleep()

            self.assertEqual(
                result["result"],
                "PASS",
            )

            self.assertEqual(
                store.read()["lifecycle"]["last_transition"],
                "sleep",
            )


    def test_wake_restores_runtime(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)

            _, store, engine = self.build_engine(
                root,
                {"alpha": noop_engine()},
            )

            engine.start()
            engine.sleep()
            result = engine.wake()

            self.assertEqual(
                result["result"],
                "PASS",
            )

            self.assertEqual(
                store.read()["status"],
                "running",
            )

'''

if anchor not in text:
    raise SystemExit("regression anchor missing")

text = text.replace(anchor, tests + anchor)

path.write_text(text)

print("Patch applied.")
PY


echo
echo "Running syntax validation..."

python3 -m compileall \
  builder/python/wlruntime/wlruntime


echo
echo "Running Runtime Engine regression..."

PYTHONPATH=builder/python/wlruntime \
python3 -m wlruntime.cli \
--root "$ROOT" \
self-test


echo
echo "Lifecycle patch complete."
