#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

ENGINE="builder/python/wlrepository/wlrepository/engine.py"
CLI="builder/python/wlrepository/wlrepository/cli.py"

echo "Applying Repository Engine doctor integration..."

python3 <<'PY'
from pathlib import Path

engine_path = Path(
    "builder/python/wlrepository/wlrepository/engine.py"
)

text = engine_path.read_text()

if "def doctor(self)" not in text:
    marker = "    def status(self) -> dict[str, Any]:\n"

    insert = '''    def doctor(self) -> dict[str, Any]:
        verification = self.verify()
        certificate = self.verify_certificate()

        return {
            "engine": "repository",
            "status": (
                "PASS"
                if (
                    verification.passed
                    and certificate.get("valid", False)
                )
                else "FAIL"
            ),
            "verification": verification.as_dict(),
            "certificate": certificate,
            "health": self.health(),
        }

'''

    if marker not in text:
        raise SystemExit(
            "engine doctor insertion point missing"
        )

    text = text.replace(
        marker,
        insert + marker,
    )

engine_path.write_text(text)


cli_path = Path(
    "builder/python/wlrepository/wlrepository/cli.py"
)

text = cli_path.read_text()

old = '''        if args.command in {"verify", "doctor"}:
            return emit_result(
                engine.verify(),
                json_output=args.json,
            )
'''

new = '''        if args.command == "verify":
            return emit_result(
                engine.verify(),
                json_output=args.json,
            )

        if args.command == "doctor":
            payload = engine.doctor()

            if args.json:
                print(
                    json.dumps(
                        payload,
                        indent=2,
                        sort_keys=True,
                    )
                )
            else:
                print(
                    "Wonderland Repository Doctor"
                )
                print(
                    f"status={payload['status']}"
                )
                print(
                    f"health={payload['health']['score']}"
                )

            return (
                0
                if payload["status"] == "PASS"
                else 1
            )
'''

if old in text:
    text = text.replace(old, new)

cli_path.write_text(text)

PY

echo
echo "Running tests..."

PYTHONPATH=builder/python/wlrepository \
python -m pytest builder/python/wlrepository/tests

echo
echo "Doctor report..."

PYTHONPATH=builder/python/wlrepository \
python -m wlrepository.cli --json doctor

echo
echo "Repository doctor integration complete."
