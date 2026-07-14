#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

ENGINE="builder/python/wlrepository/wlrepository/engine.py"
CLI="builder/python/wlrepository/wlrepository/cli.py"
TEST_ENGINE="builder/python/wlrepository/tests/test_repository_engine.py"
TEST_CLI="builder/python/wlrepository/tests/test_cli.py"

echo "Applying Repository Engine 1.2..."

python3 <<'PY'
from pathlib import Path

engine = Path("builder/python/wlrepository/wlrepository/engine.py")
text = engine.read_text()

if "def certification(self)" not in text:
    marker = "    def current_digest(self) -> str | None:\n"

    insert = '''    def certification(self) -> dict[str, Any]:
        verification = self.verify()
        health = self.health()

        return {
            "engine": "repository",
            "version": "1.2",
            "policy_digest": self.policy_digest(),
            "generated_digest": self.generated_digest(),
            "verification": verification.as_dict()["result"],
            "health_score": health["score"],
            "certified": verification.passed,
        }

'''

    if marker not in text:
        raise SystemExit("engine insertion point missing")

    text = text.replace(marker, insert + marker)

engine.write_text(text)


cli = Path("builder/python/wlrepository/wlrepository/cli.py")
text = cli.read_text()

if 'subparsers.add_parser("certify")' not in text:
    text = text.replace(
        'subparsers.add_parser("repair")\n',
        'subparsers.add_parser("repair")\n'
        '    subparsers.add_parser("certify")\n'
    )

if 'if args.command == "certify":' not in text:
    marker = '        if args.command == "tracked-ignored":\n'

    insert = '''        if args.command == "certify":
            payload = engine.certification()

            if args.json:
                print(
                    json.dumps(
                        payload,
                        indent=2,
                        sort_keys=True,
                    )
                )
            else:
                print("Wonderland Repository Certification")
                print(
                    f"verification={payload['verification']}"
                )
                print(
                    f"health_score={payload['health_score']}"
                )
                print(
                    f"certified={payload['certified']}"
                )

            return 0 if payload["certified"] else 1

'''

    if marker not in text:
        raise SystemExit("cli insertion point missing")

    text = text.replace(marker, insert + marker)

cli.write_text(text)

PY

echo "Running tests..."

PYTHONPATH=python/wlrepository \
python -m pytest python/wlrepository/tests

echo
echo "Certification:"
PYTHONPATH=python/wlrepository \
python -m wlrepository.cli --json certify

echo
echo "Repository Engine 1.2 applied."
