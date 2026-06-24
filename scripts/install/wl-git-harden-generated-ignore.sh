#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
cd "$ROOT"

rm -f .git/index.lock

cat >> .gitignore <<'EOF'

# Wonderland generated artifacts
apps/**/node_modules/
apps/**/src-tauri/target/
apps/**/*.app/
apps/**/.build/
apps/**/build/
apps/**/backups/
*.backup.*
*.dSYM/
.DS_Store
.wl/
vault/chaos/*.log
vault/chaos/*.pid
vault/08-Operations/recovery/git-rescue/*.tar.gz
EOF

git rm -r --cached --ignore-unmatch \
  apps/macos/wl-chaos-menubar/.build \
  apps/macos/wl-chaos-menubar/build \
  apps/macos/wl-chaos-menubar/backups \
  apps/tauri/wl-spin-city/node_modules \
  apps/tauri/wl-agitate/node_modules \
  apps/tauri/wl-matrix/node_modules \
  apps/tauri/wl-spin-city/src-tauri/target \
  apps/tauri/wl-agitate/src-tauri/target \
  apps/tauri/wl-matrix/src-tauri/target

git add .gitignore

TREE="$(git write-tree)"
COMMIT="$(printf '%s\n' "Harden git ignores for generated Wonderland artifacts" | git commit-tree "$TREE" -p HEAD)"
git update-ref refs/heads/main "$COMMIT"

rm -f .git/index.lock

echo "PASS git ignore hardening committed"
git log --oneline -3
