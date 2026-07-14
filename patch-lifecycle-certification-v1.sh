#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$ROOT"

STAMP="$(date +%Y%m%d-%H%M%S)"

echo "Creating backups..."

cp builder/python/wlruntime/wlruntime/regression.py \
   builder/python/wlruntime/wlruntime/regression.py.before-cert-v1.$STAMP

cp builder/python/wlruntime/wlruntime/certification.py \
   builder/python/wlruntime/wlruntime/certification.py.before-cert-v1.$STAMP


python3 <<'PY'
from pathlib import Path


# ------------------------------------------------------------
# regression.py
# ------------------------------------------------------------

p = Path(
    "builder/python/wlruntime/wlruntime/regression.py"
)

text = p.read_text()


marker = '''
    def test_structural_verify_does_not_execute_health(self) -> None:
'''

insert = '''
    def test_restart_restores_running_state(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)

            _, store, engine = self.build_engine(
                root,
                {
                    "alpha": noop_engine(),
                },
            )

            engine.start()

            result = engine.restart()

            self.assertEqual(
                result["result"],
                "PASS",
            )

            state = store.read()

            self.assertEqual(
                state["status"],
                "running",
            )


    def test_sleep_records_transition(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)

            _, store, engine = self.build_engine(
                root,
                {
                    "alpha": noop_engine(),
                },
            )

            engine.start()

            result = engine.sleep()

            self.assertEqual(
                result["result"],
                "PASS",
            )

            state = store.read()

            self.assertEqual(
                state["status"],
                "stopped",
            )

            self.assertEqual(
                state["lifecycle"]["last_transition"],
                "sleep",
            )


    def test_wake_restores_running_state(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)

            _, store, engine = self.build_engine(
                root,
                {
                    "alpha": noop_engine(),
                },
            )

            engine.start()
            engine.sleep()

            result = engine.wake()

            self.assertEqual(
                result["result"],
                "PASS",
            )

            state = store.read()

            self.assertEqual(
                state["status"],
                "running",
            )

            self.assertEqual(
                state["lifecycle"]["last_transition"],
                "wake",
            )


'''

if marker not in text:
    raise SystemExit(
        "regression insertion marker missing"
    )

text = text.replace(
    marker,
    insert + marker,
)

p.write_text(text)


# ------------------------------------------------------------
# certification.py
# ------------------------------------------------------------

p = Path(
    "builder/python/wlruntime/wlruntime/certification.py"
)

text = p.read_text()

if "restart" not in text:
    print(
        "Certification module does not contain "
        "simple lifecycle checks; regression "
        "coverage added only."
    )

p.write_text(text)

print("Lifecycle Certification v1 applied.")
PY


echo "Compile validation..."

python3 -m compileall \
builder/python/wlruntime/wlruntime


echo "Regression validation..."

PYTHONPATH=builder/python/wlruntime \
python3 -m wlruntime.cli \
--root "$ROOT" \
self-test
