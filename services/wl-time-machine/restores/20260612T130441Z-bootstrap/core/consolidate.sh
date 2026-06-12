#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="/Users/wonderland/Wonderland"
VAULT_SOURCE="$ROOT_DIR/vault"
OBSIDIAN_TARGET="$ROOT_DIR/intelligence/obsidian"
echo "=== 🔄 Executing Wonderland-V4 Governance Document Consolidation ==="
mkdir -p "$OBSIDIAN_TARGET"/{00-Core,01-Architecture,02-Registry,03-Platform,04-Automation,05-Operations,06-Recovery,07-Security}
for folder in $(ls "$VAULT_SOURCE" | grep -E '^[0-9]{2}-'); do
    TARGET_SUBFOLDER=$(echo "$folder" | tr '[:lower:]' '[:upper:]' | sed 's/GOVERNANCE/CORE/g')
    if [ -d "$VAULT_SOURCE/$folder" ]; then cp -R "$VAULT_SOURCE/$folder/"* "$OBSIDIAN_TARGET/$TARGET_SUBFOLDER/" 2>/dev/null || true; fi
done
cp "$VAULT_SOURCE"/*.md "$OBSIDIAN_TARGET/00-Core/" 2>/dev/null || true
if [ ! -f "$OBSIDIAN_TARGET/00-Core/Governance.md" ]; then
    cat << 'GOV_EOF' > "$OBSIDIAN_TARGET/00-Core/Governance.md"
---
system_identity: "Wonderland Operator"
system_email: "operator@wonderland.internal"
network_kill_switch: true
proxy_port: 9050
---
# ⚖️ System Governance Matrix
GOV_EOF
fi
echo "[SUCCESS] Documentation aligned inside intelligence/obsidian/."
