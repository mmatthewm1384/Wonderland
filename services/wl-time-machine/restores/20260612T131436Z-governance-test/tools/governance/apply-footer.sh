#!/usr/bin/env bash
set -euo pipefail

FOOTER="vault/governance/standards/governance-footer.md"

find vault \
  -type f \
  \( -path "*/docs/*.md" \
     -o -path "*/governance/*.md" \
     -o -path "*/recovery/*.md" \
     -o -path "*/services/*.md" \
     -o -path "*/security/*.md" \
     -o -path "*/operations/*.md" \
     -o -path "*/policies/*.md" \
     -o -path "*/runbooks/*.md" \) \
  ! -path "*/reports/*" \
  ! -path "*/audits/*" \
  ! -path "*/templates/*" |
while read -r file; do
  if grep -q "Runtime state is disposable." "$file"; then
    continue
  fi

  {
    echo
    cat "$FOOTER"
  } >> "$file"

  echo "UPDATED $file"
done
