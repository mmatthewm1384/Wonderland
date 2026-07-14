#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_HOME:-$HOME/Wonderland}"

cd "$ROOT"

echo "Creating backups..."

backup() {
  local file="$1"
  cp "$file" "$file.bak.$(date +%Y%m%dT%H%M%S)"
}

ENGINE="builder/python/wlruntime/wlruntime/engine.py"
CERT="builder/python/wlruntime/wlruntime/certification.py"

[[ -f "$ENGINE" ]] || {
  echo "Missing $ENGINE"
  exit 1
}

[[ -f "$CERT" ]] || {
  echo "Missing $CERT"
  exit 1
}

backup "$ENGINE"
backup "$CERT"

echo "Patching runtime lifecycle recovery..."

python3 <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlruntime/wlruntime/engine.py"
)

text = path.read_text()

marker = """
    def start(self, *, dry_run: bool = False) -> dict[str, Any]:
"""

if "_recover_stale_operation" not in text:
    insert = """
    def _recover_stale_operation(
        self,
        state: dict[str, Any],
    ) -> dict[str, Any]:
        \"\"\"Recover interrupted lifecycle transitions.\"\"\"

        operation = state.get("operation")

        if operation not in {
            "start",
            "stop",
        }:
            return state

        previous_status = state.get("status")

        state["last_error"] = {
            "action": "recovery",
            "message": (
                "Recovered interrupted lifecycle operation"
            ),
            "previous_status": previous_status,
            "occurred_at": utc_now(),
        }

        state["operation"] = None
        state["operation_id"] = None

        if previous_status in {
            "starting",
            "stopping",
            "rolling-back",
        }:
            state["status"] = (
                "running"
                if state.get("started_engines")
                else "stopped"
            )

        self.state_store.write(state)

        return state


"""

    text = text.replace(
        marker,
        insert + marker,
    )


text = text.replace(
    """
        state = self.state_store.read()

        if state["status"] == "running":
""",
    """
        state = self.state_store.read()

        state = self._recover_stale_operation(
            state
        )

        if state["status"] == "running":
"""
)


text = text.replace(
    """
        state = self.state_store.read()

            if state["status"] == "stopped":
""",
    """
        state = self.state_store.read()

        state = self._recover_stale_operation(
            state
        )

        if state["status"] == "stopped":
"""
)


path.write_text(text)

PY


echo "Patching certification interrupt handling..."

python3 <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlruntime/wlruntime/certification.py"
)

text = path.read_text()

old = """
        except Exception as exc:
            checks["certification_execution"] = False
            errors.append(
                f"{type(exc).__name__}: {exc}"
            )

            self._best_effort_cleanup(
                evidence_root=evidence_root,
            )
"""

new = """
        except KeyboardInterrupt:
            checks["certification_execution"] = False

            errors.append(
                "KeyboardInterrupt: certification interrupted"
            )

            recovery = {
                "interrupted": True,
                "cleanup_attempted": True,
            }

            try:
                cleanup = self.engine.stop()
                recovery["cleanup"] = cleanup

            except Exception as exc:
                recovery["cleanup_error"] = (
                    f"{type(exc).__name__}: {exc}"
                )

            write_json(
                evidence_root / "recovery.json",
                recovery,
            )

            evidence["recovery"] = str(
                evidence_root / "recovery.json"
            )

        except Exception as exc:
            checks["certification_execution"] = False
            errors.append(
                f"{type(exc).__name__}: {exc}"
            )

            self._best_effort_cleanup(
                evidence_root=evidence_root,
            )
"""

if old not in text:
    raise SystemExit(
        "certification exception block not found"
    )

text = text.replace(
    old,
    new,
)

path.write_text(text)

PY


echo "Adding lifecycle recovery regression test..."

TEST="builder/python/wlruntime/wlruntime/regression.py"

if [[ -f "$TEST" ]]; then

python3 <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlruntime/wlruntime/regression.py"
)

text = path.read_text()

if "test_interrupted_stop_recovers_state" not in text:

    anchor = "\n\nclass LifecycleContractTests"

    addition = """

    def test_interrupted_stop_recovers_state(self):
        state = self.engine.state_store.default_state()

        state.update(
            {
                "status": "stopping",
                "operation": "stop",
                "operation_id": "interrupted-test",
                "started_engines": [],
            }
        )

        self.engine.state_store.write(state)

        recovered = (
            self.engine.state_store.read()
        )

        recovered = (
            self.engine._recover_stale_operation(
                recovered
            )
        )

        self.assertEqual(
            recovered["status"],
            "stopped",
        )

        self.assertIsNone(
            recovered["operation"]
        )
"""

    text = text.replace(
        anchor,
        addition + anchor,
    )

    path.write_text(text)

PY

fi


echo "Running validation..."

python3 -m compileall \
builder/python/wlruntime/wlruntime


echo
echo "Lifecycle Certification v2.2 patch complete."
echo
echo "Next:"
echo
echo "PYTHONPATH=builder/python/wlruntime \\"
echo "python3 -m wlruntime.cli --root ~/Wonderland self-test"
echo
echo "Then:"
echo
echo "wl runtime certify --mode full"
