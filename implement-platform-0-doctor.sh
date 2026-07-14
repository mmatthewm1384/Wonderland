#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$(pwd)}"
cd "$ROOT"

mkdir -p docs/philosophy docs/releases docs/standards docs/design .github/pull_request_template.md.d lib/philosophy bin

cat > docs/philosophy/INDEX.md <<'DOC'
# Wonderland Philosophy Index

Platform 0 is Wonderland's constitutional layer.

## Core Documents

- `NORTH_STAR.md`
- `MANIFESTO.md`
- `CONSTITUTION.md`
- `DESIGN_SYSTEM.md`

## Standards

- `docs/standards/ENGINEERING_STANDARD.md`
- `docs/standards/EXPERIENCE_STANDARD.md`
- `docs/standards/DOCUMENTATION_STANDARD.md`

## Design Systems

- `docs/design/MATERIAL_SYSTEM.md`
- `docs/design/MOTION_SYSTEM.md`

## Release

- `docs/releases/PLATFORM-0.0-PHILOSOPHY-RELEASE.md`

## Rule

Every future decision should trace back to the North Star:

> Create a world where engineering becomes art, and art remains engineered.
DOC

cat > docs/philosophy/RELEASE.json <<'JSON'
{
  "name": "Wonderland Platform 0.0",
  "codename": "Luxury Engineering",
  "type": "constitutional",
  "status": "released",
  "release_date": "2026-07-06",
  "north_star": "Create a world where engineering becomes art, and art remains engineered.",
  "principle": "Leave behind evidence that someone cared."
}
JSON

cat > .github/pull_request_template.md <<'DOC'
# Pull Request

## Summary

Describe what changed and why.

## Manifesto Check

- [ ] Engineered with purpose
- [ ] Crafted with soul
- [ ] Improves Wonderland
- [ ] Avoids unnecessary complexity
- [ ] Consistent with the North Star

## Engineering Check

- [ ] Reliable
- [ ] Recoverable
- [ ] Observable where appropriate
- [ ] Maintainable
- [ ] Documented
- [ ] Verified

## North Star

> Create a world where engineering becomes art, and art remains engineered.
DOC

cat > bin/wl-platform-0-doctor <<'SH'
#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ROOT"

fail=0

check_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    printf 'PASS %-55s\n' "$file"
  else
    printf 'FAIL %-55s\n' "$file"
    fail=1
  fi
}

check_contains() {
  local file="$1"
  local text="$2"
  if [[ -f "$file" ]] && grep -Fq "$text" "$file"; then
    printf 'PASS %-55s contains required text\n' "$file"
  else
    printf 'FAIL %-55s missing required text\n' "$file"
    fail=1
  fi
}

echo "Wonderland Platform 0 Doctor"
echo

check_file "NORTH_STAR.md"
check_file "MANIFESTO.md"
check_file "CONSTITUTION.md"
check_file "DESIGN_SYSTEM.md"
check_file "docs/philosophy/INDEX.md"
check_file "docs/philosophy/RELEASE.json"
check_file "docs/releases/PLATFORM-0.0-PHILOSOPHY-RELEASE.md"
check_file "docs/standards/ENGINEERING_STANDARD.md"
check_file "docs/standards/EXPERIENCE_STANDARD.md"
check_file "docs/standards/DOCUMENTATION_STANDARD.md"
check_file "docs/design/MATERIAL_SYSTEM.md"
check_file "docs/design/MOTION_SYSTEM.md"
check_file ".github/pull_request_template.md"
check_file "bin/wl-philosophy"
check_file "bin/wl-north-star"
check_file "bin/wl-platform-0-verify"

echo

check_contains "NORTH_STAR.md" "engineering becomes art"
check_contains "MANIFESTO.md" "This is Wonderland"
check_contains "docs/philosophy/RELEASE.json" "Luxury Engineering"
check_contains ".github/pull_request_template.md" "Manifesto Check"

echo

if [[ "$fail" -eq 0 ]]; then
  echo "RESULT PASS"
else
  echo "RESULT FAIL"
  exit 1
fi
SH

chmod +x bin/wl-platform-0-doctor

if [[ -f bin/wl ]] && ! grep -q 'platform-0-doctor)' bin/wl; then
  cp bin/wl "bin/wl.backup-platform-0-doctor-$(date +%Y%m%d-%H%M%S)"

  python3 - <<'PY'
from pathlib import Path

p = Path("bin/wl")
s = p.read_text()

insert = '''\
      platform-0-doctor)
        exec "$WL_ROOT/bin/wl-platform-0-doctor" "$@"
        ;;
'''

lines = s.splitlines(True)
out = []
inserted = False

for line in lines:
    out.append(line)
    if not inserted and line.lstrip().startswith("case ") and line.rstrip().endswith(" in"):
        out.append(insert)
        inserted = True

if not inserted:
    raise SystemExit("FAIL could not patch bin/wl dispatch")

p.write_text("".join(out))
PY
fi

cat <<'DONE'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Platform 0 Doctor Installed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Added:

✓ docs/philosophy/INDEX.md
✓ docs/philosophy/RELEASE.json
✓ .github/pull_request_template.md
✓ bin/wl-platform-0-doctor
✓ wl platform-0-doctor dispatch

Run:

  wl platform-0-doctor

Commit:

  git add .github bin docs
  git commit -m "add Platform 0 doctor and manifesto governance"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DONE
