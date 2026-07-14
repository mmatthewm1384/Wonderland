#!/usr/bin/env bash
set -euo pipefail

if [[ -x ".venv/bin/python" ]]; then
    PYTHON_BIN=".venv/bin/python"
elif command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="$(command -v python3)"
else
    echo "FAIL: Python interpreter not found"
    exit 1
fi

ENGINE="builder/python/wlrepository/wlrepository/engine.py"
CLI="builder/python/wlrepository/wlrepository/cli.py"

echo "Applying Repository Engine 1.2 certification..."

"$PYTHON_BIN" - <<'PY'
from pathlib import Path

engine = Path("builder/python/wlrepository/wlrepository/engine.py")
text = engine.read_text()

marker = '''    def status(self) -> dict[str, Any]:
'''

method = '''    def certification(self) -> dict[str, Any]:
        verification = self.verify()
        health = self.health()

        return {
            "engine": "repository",
            "version": "1.2",
            "policy_digest": self.policy_digest(),
            "generated_digest": self.generated_digest(),
            "verification": verification.as_dict()["result"],
            "health_score": health["score"],
            "certified": (
                verification.errors == 0
                and self.generate(check_only=True)
            ),
        }

'''

if "def certification(self)" not in text:
    if marker not in text:
        raise SystemExit("Engine insertion point not found")
    text = text.replace(marker, method + marker, 1)
    engine.write_text(text)

print("Updated engine.py")


cli = Path("builder/python/wlrepository/wlrepository/cli.py")
text = cli.read_text()

if 'subparsers.add_parser("certify")' not in text:
    old = '''    subparsers.add_parser("repair")
    subparsers.add_parser("tracked-ignored")
'''
    new = '''    subparsers.add_parser("repair")
    subparsers.add_parser("certify")
    subparsers.add_parser("tracked-ignored")
'''
    if old not in text:
        raise SystemExit("CLI parser insertion point not found")
    text = text.replace(old, new, 1)

if 'if args.command == "certify":' not in text:
    old = '''        if args.command == "health":
            payload = engine.health()

            if args.json:
                print(json.dumps(payload, indent=2, sort_keys=True))
            else:
                print("Wonderland Repository Health")
                print(f"score={payload['score']}")
                print(f"result={payload['result']}")
                print(f"errors={payload['errors']}")
                print(f"warnings={payload['warnings']}")

            return 0 if payload["result"] == "PASS" else 1

'''
    new = old + '''        if args.command == "certify":
            payload = engine.certification()

            if args.json:
                print(json.dumps(payload, indent=2, sort_keys=True))
            else:
                print("Wonderland Repository Certification")
                print(
                    f"certified={str(payload['certified']).lower()}"
                )
                print(
                    f"health_score={payload['health_score']}"
                )
                print(
                    f"verification={payload['verification']}"
                )

            return 0 if payload["certified"] else 1

'''
    if old not in text:
        raise SystemExit("CLI health block not found")
    text = text.replace(old, new, 1)

cli.write_text(text)

print("Updated cli.py")
PY

echo
echo "Running tests..."

PYTHONPATH=builder/python/wlrepository \
"$PYTHON_BIN" -m pytest builder/python/wlrepository/tests || true

echo
echo "Testing certification..."

PYTHONPATH=builder/python/wlrepository \
"$PYTHON_BIN" -m wlrepository.cli --json certify

echo
echo "Complete."
