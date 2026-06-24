#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
DATE="$(date +%Y%m%d-%H%M%S)"
BACKUP="$WL_HOME/backups/eza-layout-$DATE"

mkdir -p "$WL_HOME/bin" "$BACKUP"

if ! command -v eza >/dev/null 2>&1; then
  brew install eza
fi

cat > "$WL_HOME/bin/wl-ls" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if command -v eza >/dev/null 2>&1; then
  exec eza -lah --group-directories-first --git --icons=auto "$@"
else
  exec ls -lah "$@"
fi
EOF

cat > "$WL_HOME/bin/wl-lt" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

DEPTH="${WL_TREE_DEPTH:-3}"

if command -v eza >/dev/null 2>&1; then
  exec eza --tree --level="$DEPTH" --group-directories-first --git --icons=auto "$@"
elif command -v tree >/dev/null 2>&1; then
  exec tree -L "$DEPTH" "$@"
else
  exec find "${1:-.}" -maxdepth "$DEPTH" | sort
fi
EOF

chmod +x "$WL_HOME/bin/wl-ls" "$WL_HOME/bin/wl-lt"

ZSHRC="$HOME/.zshrc"
cp "$ZSHRC" "$BACKUP/zshrc.bak" 2>/dev/null || true

if ! grep -q "Wonderland eza layout" "$ZSHRC" 2>/dev/null; then
  cat >> "$ZSHRC" <<'EOF'

# Wonderland eza layout
export LS_COLORS='di=36:fi=0:ln=35:ex=32'
alias ls='wl-ls'
alias ll='wl-ls'
alias la='wl-ls -a'
alias lt='wl-lt'
alias lta='WL_TREE_DEPTH=5 wl-lt'
alias lg='wl-lt ~/Wonderland/vault/09-Governance'
alias ltm='wl-lt ~/Wonderland/vault/09-Governance/theomatrix'
EOF
fi

echo "PASS eza"
echo "PASS wl-ls"
echo "PASS wl-lt"
echo "backup: $BACKUP"
echo
"$WL_HOME/bin/wl-ls" "$WL_HOME/vault/09-Governance" || true
