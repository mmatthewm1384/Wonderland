#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

ENGINE="builder/python/wlrepository/wlrepository/engine.py"
CLI="builder/python/wlrepository/wlrepository/cli.py"

echo "Applying Repository Engine 1.2 hardening..."

python3 <<'PY'
from pathlib import Path

engine = Path(
    "builder/python/wlrepository/wlrepository/engine.py"
)

text = engine.read_text()

# Add certificate path
old = '''        self.policy_path = self.root / "policy/repository/policy.json"
        self.gitignore_path = self.root / ".gitignore"
'''

new = '''        self.policy_path = self.root / "policy/repository/policy.json"
        self.gitignore_path = self.root / ".gitignore"
        self.certificate_path = (
            self.root /
            ".state/repository/certificate.json"
        )
'''

if "self.certificate_path" not in text:
    if old not in text:
        raise SystemExit("constructor insertion point missing")
    text = text.replace(old, new)


# Add certificate methods
if "def write_certificate" not in text:
    marker = "    def policy_digest(self) -> str:\n"

    insert = '''    def write_certificate(self) -> dict[str, Any]:
        certificate = self.certification()

        self.certificate_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        self.certificate_path.write_text(
            json.dumps(
                certificate,
                indent=2,
                sort_keys=True,
            ) + "\\n",
            encoding="utf-8",
        )

        return certificate

    def load_certificate(self) -> dict[str, Any] | None:
        if not self.certificate_path.exists():
            return None

        return json.loads(
            self.certificate_path.read_text(
                encoding="utf-8"
            )
        )

'''

    if marker not in text:
        raise SystemExit("certificate insertion point missing")

    text = text.replace(marker, insert + marker)


# Add drift verification
if "POLICY_DIGEST_MISMATCH" not in text:
    marker = "        try:\n            tracked_ignored = self.tracked_ignored()\n"

    insert = '''        certificate = self.load_certificate()

        if certificate:
            if (
                certificate.get("policy_digest")
                != self.policy_digest()
            ):
                result.add(
                    "ERROR",
                    "POLICY_DIGEST_MISMATCH",
                    (
                        "repository policy changed "
                        "after certification"
                    ),
                    "policy/repository/policy.json",
                )

'''

    if marker not in text:
        raise SystemExit("verification insertion point missing")

    text = text.replace(marker, insert + marker)


engine.write_text(text)


cli = Path(
    "builder/python/wlrepository/wlrepository/cli.py"
)

text = cli.read_text()

old = '''        if args.command == "certify":
            payload = engine.certification()
'''

new = '''        if args.command == "certify":
            payload = engine.write_certificate()
'''

if old in text:
    text = text.replace(old, new)

cli.write_text(text)

PY

echo
echo "Running tests..."

PYTHONPATH=builder/python/wlrepository \
python -m pytest builder/python/wlrepository/tests

echo
echo "Creating certificate..."

PYTHONPATH=builder/python/wlrepository \
python -m wlrepository.cli --json certify

echo
echo "Repository Engine 1.2 hardening applied."
