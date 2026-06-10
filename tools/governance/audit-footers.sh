#!/usr/bin/env bash
set -euo pipefail

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
    printf "PASS %s\n" "$file"
  else
    printf "FAIL %s\n" "$file"
  fi
done
