#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FILE="$ROOT/builder/python/wlplatform/wlplatform/controller.py"

cp "$FILE" "$FILE.backup.$(date +%Y%m%d-%H%M%S)"

python3 - <<'PY'
from pathlib import Path

p = Path(
"builder/python/wlplatform/wlplatform/controller.py"
)

text = p.read_text()

if "from .certification_state import CertificationState" not in text:
    text = text.replace(
        "from .context import PlatformContext\n",
        "from .context import PlatformContext\nfrom .certification_state import CertificationState\n",
    )

start = text.index(
    "    def _core_checks("
)

end = text.index(
    "    def _optional_checks",
)

replacement = '''    def _core_checks(self) -> tuple[Check, ...]:

        def certification_check(
            context: PlatformContext,
        ) -> CheckResult:

            state = CertificationState(
                context.root
            ).collect()

            engines = state.get(
                "engines",
                {}
            )

            failures = [
                name
                for name, data in engines.items()
                if data.get("status") != "PASS"
            ]

            if failures:
                return CheckResult(
                    name="certification",
                    status=Status.FAIL,
                    summary=(
                        "failed certifications: "
                        + ", ".join(failures)
                    ),
                )

            return CheckResult(
                name="certification",
                status=Status.PASS,
                summary="all certification artifacts passed",
            )

        return (
            verify_registry,
            certification_check,
            verify_manifests,
        )

'''

text = text[:start] + replacement + text[end:]

p.write_text(text)
PY

echo "patched: $FILE"
