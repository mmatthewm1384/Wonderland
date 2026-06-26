#!/usr/bin/env bash
set -euo pipefail

CONSOLE_USER="$(stat -f %Su /dev/console)"
CURRENT_USER="$(id -un)"

if [ "$CONSOLE_USER" != "$CURRENT_USER" ]; then
  echo "DENY macos-auth not-console-user"
  exit 1
fi

/usr/bin/osascript -e 'do shell script "true" with administrator privileges' >/dev/null

echo "PASS macos-auth"
