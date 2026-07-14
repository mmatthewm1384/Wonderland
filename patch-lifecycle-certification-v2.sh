#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$ROOT"

STAMP="$(date +%Y%m%d-%H%M%S)"

echo "Creating backups..."

cp builder/python/wlruntime/wlruntime/certification.py \
builder/python/wlruntime/wlruntime/certification.py.before-cert-v2.$STAMP


python3 <<'PY'
from pathlib import Path


path = Path(
    "builder/python/wlruntime/wlruntime/certification.py"
)

text = path.read_text()


# Add imports
if "json" not in text.splitlines()[0:20]:
    text = text.replace(
        "from __future__ import annotations\n",
        "from __future__ import annotations\n\nimport json\n",
    )


# Insert evidence writer before certify()
marker = "    def certify("

if marker not in text:
    raise SystemExit(
        "certify method not found"
    )


insert = r'''
    def _write_lifecycle_evidence(
        self,
        name: str,
        payload: dict,
    ) -> Path:
        root = (
            self.root
            / "vault"
            / "08-Operations"
            / "certification"
            / "runtime"
        )

        root.mkdir(
            parents=True,
            exist_ok=True,
        )

        path = root / f"{name}.json"

        path.write_text(
            json.dumps(
                payload,
                indent=2,
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )

        return path


    def _run_lifecycle_certification(
        self,
    ) -> dict:
        checks = {}
        evidence = {}

        lifecycle = (
            ("start", self.engine.start),
            ("stop", self.engine.stop),
            ("restart", self.engine.restart),
            ("sleep", self.engine.sleep),
            ("wake", self.engine.wake),
            ("recovery", self.engine.recover),
        )

        for name, operation in lifecycle:
            try:
                result = operation()

                payload = {
                    "result": result.get(
                        "result",
                        "PASS",
                    ),
                    "operation": name,
                    "state": result.get(
                        "state",
                        {},
                    ),
                }

                path = self._write_lifecycle_evidence(
                    name,
                    payload,
                )

                evidence[name] = str(path)

                checks[name] = (
                    "PASS"
                    if payload["result"] == "PASS"
                    else "FAIL"
                )

            except Exception as exc:
                checks[name] = "FAIL"

                path = self._write_lifecycle_evidence(
                    name,
                    {
                        "result": "FAIL",
                        "operation": name,
                        "error": str(exc),
                    },
                )

                evidence[name] = str(path)

        return {
            "checks": checks,
            "evidence": evidence,
            "result": (
                "PASS"
                if all(
                    value == "PASS"
                    for value in checks.values()
                )
                else "FAIL"
            ),
        }


'''


text = text.replace(
    marker,
    insert + marker,
)


# Add execution into full certification path
old = """
        if mode == "full":
"""

if old not in text:
    raise SystemExit(
        "full mode marker missing"
    )


new = """
        if mode == "full":
            lifecycle = self._run_lifecycle_certification()

            checks.update(
                lifecycle["checks"]
            )

            payload["lifecycle_evidence"] = (
                lifecycle["evidence"]
            )

            if lifecycle["result"] != "PASS":
                errors.append(
                    "lifecycle certification failed"
                )


        if mode == "full":
"""

text = text.replace(
    old,
    new,
    1,
)


path.write_text(text)

print(
    "Lifecycle Certification v2 applied."
)
PY


echo "Compile validation..."

python3 -m compileall \
builder/python/wlruntime/wlruntime


echo "Regression validation..."

PYTHONPATH=builder/python/wlruntime \
python3 -m wlruntime.cli \
--root "$ROOT" \
self-test
