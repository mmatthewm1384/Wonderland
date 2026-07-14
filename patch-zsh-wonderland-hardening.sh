#!/usr/bin/env bash
set -Eeuo pipefail

ZSHRC="$HOME/.zshrc"

[[ -f "$ZSHRC" ]] || {
  echo "Missing $ZSHRC"
  exit 1
}

echo "Creating backup..."
cp "$ZSHRC" "$ZSHRC.bak.$(date +%Y%m%dT%H%M%SZ)"

python3 - "$ZSHRC" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

# -------------------------------------------------------------------
# Disable correction
# -------------------------------------------------------------------

if "unsetopt correct" not in text:
    marker = "# 70. Completion system"

    if marker in text:
        text = text.replace(
            marker,
            """# Disable aggressive command correction.
# Versioned development scripts should execute exactly as typed.
unsetopt correct
unsetopt correct_all

# 70. Completion system""",
            1,
        )
    else:
        text = (
            "# Disable aggressive command correction.\n"
            "unsetopt correct\n"
            "unsetopt correct_all\n\n"
            + text
        )

# -------------------------------------------------------------------
# Harden readonly zcompdump
# -------------------------------------------------------------------

old = 'readonly _WL_ZCOMP_DUMP="$XDG_CACHE_HOME/zsh/zcompdump"'

new = '''if [[ -z "${_WL_ZCOMP_DUMP:-}" ]]; then
  readonly _WL_ZCOMP_DUMP="$XDG_CACHE_HOME/zsh/zcompdump"
fi'''

if old in text:
    text = text.replace(old, new, 1)
elif 'if [[ -z "${_WL_ZCOMP_DUMP:-}" ]]; then' not in text:
    raise SystemExit(
        "Could not find zcompdump assignment block"
    )

path.write_text(text)

print("Patched:", path)
PY

echo "Checking zsh syntax..."
zsh -n "$ZSHRC"

echo
echo "Patch complete."
echo
echo "Reload:"
echo "source ~/.zshrc"
echo
echo "Verify:"
echo "setopt | grep correct || true"
