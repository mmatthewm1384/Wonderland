#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="${WL_AUTHORITY_ROOT:-${WL_HOME:-$HOME/Wonderland}}"
SECRETS_DIR="$ROOT_DIR/secrets"
# Asserts directory presence, checks for 700 POSIX permissions, verifies Git ignore status.
