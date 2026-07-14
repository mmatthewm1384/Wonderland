#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_HOME:-$PWD}"

cd "$ROOT"

echo "Creating backups..."

timestamp="$(date +%Y%m%d-%H%M%S)"

for file in \
  bin/wl-runtime-adapter \
  builder/python/wlruntime/wlruntime/engine.py \
  builder/python/wlruntime/wlruntime/regression.py
do
  cp "$file" "$file.bak.$timestamp"
done

echo "Patching runtime adapter..."

python3 - <<'PY'
from pathlib import Path

path = Path("bin/wl-runtime-adapter")
text = path.read_text()

old = '''  rootless-runtime:stop)
    run_first_supported \
      "rootless-runtime stop" \
      "bin/wl-rootless|stop" \
      "bin/wl|rootless|stop"
    ;;
'''

new = '''  rootless-runtime:stop)
    if limactl list | awk '
      $1 == "wonderland-rootless" && $2 == "Stopped" {
        found=1
      }
      END {
        exit(found ? 0 : 1)
      }
    '
    then
      printf 'PASS rootless-runtime already stopped\\\\n'
      exit 0
    fi

    run_first_supported \
      "rootless-runtime stop" \
      "bin/wl-rootless|stop" \
      "bin/wl|rootless|stop"
    ;;
'''

if old not in text:
    raise SystemExit("adapter stop marker missing")

path.write_text(text.replace(old, new))
PY


echo "Adding subprocess timeout protection..."

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlruntime/wlruntime/engine.py"
)

text = path.read_text()

old = '''        completed = subprocess.run(
            list(command.argv),
            cwd=self.root,
            text=True,
            capture_output=True,
            check=False,
        )
'''

new = '''        try:
            completed = subprocess.run(
                list(command.argv),
                cwd=self.root,
                text=True,
                capture_output=True,
                timeout=command.timeout_seconds,
                check=False,
            )
        except subprocess.TimeoutExpired as exc:
            return {
                "status": "FAIL",
                "argv": list(command.argv),
                "returncode": None,
                "error": (
                    f"command timeout after "
                    f"{command.timeout_seconds}s"
                ),
                "stdout": exc.stdout or "",
                "stderr": exc.stderr or "",
                "finished_at": utc_now(),
            }
'''

if old not in text:
    raise SystemExit("subprocess marker missing")

path.write_text(text.replace(old, new))
PY


echo "Adding regression coverage..."

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlruntime/wlruntime/regression.py"
)

text = path.read_text()

insert = '''

    def test_stop_when_runtime_already_stopped_is_idempotent(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)

            _, store, engine = self.build_engine(
                root,
                {
                    "alpha": noop_engine(),
                },
            )

            first = engine.stop()
            second = engine.stop()

            self.assertFalse(first["changed"])
            self.assertFalse(second["changed"])

            state = store.read()

            self.assertEqual(
                state["status"],
                "stopped",
            )
'''

marker = '''
    def test_structural_verify_does_not_execute_health(self) -> None:
'''

if marker not in text:
    raise SystemExit("regression marker missing")

path.write_text(
    text.replace(marker, insert + "\n" + marker)
)
PY


echo "Compile validation..."

python3 -m compileall \
  builder/python/wlruntime/wlruntime


echo "Runtime regression..."

PYTHONPATH=builder/python/wlruntime \
python3 -m wlruntime.cli \
--root "$ROOT" \
self-test


echo
echo "Lifecycle Certification v2.1 patch complete."
