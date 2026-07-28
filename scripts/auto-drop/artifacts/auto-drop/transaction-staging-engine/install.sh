#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

EXECUTOR="$ROOT/scripts/auto-drop/lib/executor.sh"

if [[ ! -f "$EXECUTOR" ]]; then
    echo "ERROR: executor.sh missing"
    exit 1
fi

cp "$EXECUTOR" "$EXECUTOR.backup.$(date +%Y%m%d%H%M%S)"

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/auto-drop/lib/executor.sh")

text = path.read_text()

marker = "echo \"Workspace created:\""

if "STAGING ARTIFACT" not in text:
    text = text.replace(
        marker,
        marker + '''
        
echo "STAGING ARTIFACT"

cp -R "$ARTIFACT_PATH"/* "$WORKSPACE"/

if [[ ! -f "$WORKSPACE/install.sh" ]]; then
    echo "ERROR: Artifact staging failed"
    exit 1
fi

echo "ARTIFACT STAGED"
'''
    )

path.write_text(text)
PY

echo "Transaction staging engine installed"
