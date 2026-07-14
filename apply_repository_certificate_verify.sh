#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

ENGINE="builder/python/wlrepository/wlrepository/engine.py"
CLI="builder/python/wlrepository/wlrepository/cli.py"

echo "Adding certificate verification..."

python3 <<'PY'
from pathlib import Path

engine = Path(
    "builder/python/wlrepository/wlrepository/engine.py"
)

text = engine.read_text()

if "def verify_certificate" not in text:
    marker = "    def status(self) -> dict[str, Any]:\n"

    insert = '''    def verify_certificate(self) -> dict[str, Any]:
        certificate = self.load_certificate()

        if certificate is None:
            return {
                "certificate": False,
                "valid": False,
                "checks": {
                    "certificate": "MISSING",
                },
            }

        checks = {}

        checks["policy_digest"] = (
            "PASS"
            if certificate.get("policy_digest")
            == self.policy_digest()
            else "FAIL"
        )

        checks["generated_digest"] = (
            "PASS"
            if certificate.get("generated_digest")
            == self.generated_digest()
            else "FAIL"
        )

        verification = self.verify()

        checks["verification"] = (
            "PASS"
            if verification.passed
            else "FAIL"
        )

        valid = all(
            value == "PASS"
            for value in checks.values()
        )

        return {
            "certificate": True,
            "valid": valid,
            "checks": checks,
        }

'''

    if marker not in text:
        raise SystemExit(
            "engine insertion point missing"
        )

    text = text.replace(
        marker,
        insert + marker,
    )

engine.write_text(text)


cli = Path(
    "builder/python/wlrepository/wlrepository/cli.py"
)

text = cli.read_text()

if 'subparsers.add_parser("verify-certificate")' not in text:
    text = text.replace(
        'subparsers.add_parser("certify")\n',
        'subparsers.add_parser("certify")\n'
        '    subparsers.add_parser("verify-certificate")\n',
    )


if 'if args.command == "verify-certificate":' not in text:
    marker = '        if args.command == "tracked-ignored":\n'

    insert = '''        if args.command == "verify-certificate":
            payload = engine.verify_certificate()

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
                    "Repository Certificate Verification"
                )

                for key, value in payload[
                    "checks"
                ].items():
                    print(
                        f"{key}={value}"
                    )

                print(
                    f"VALID={payload['valid']}"
                )

            return 0 if payload["valid"] else 1

'''

    if marker not in text:
        raise SystemExit(
            "cli insertion point missing"
        )

    text = text.replace(
        marker,
        insert + marker,
    )

cli.write_text(text)

PY

echo
echo "Running tests..."

PYTHONPATH=builder/python/wlrepository \
python -m pytest builder/python/wlrepository/tests

echo
echo "Verifying certificate..."

PYTHONPATH=builder/python/wlrepository \
python -m wlrepository.cli --json verify-certificate

echo
echo "Certificate verification added."
