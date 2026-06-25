#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
VAULT="$WL_HOME/vault"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$VAULT/99-Archive/operator-migration-$STAMP"

mkdir -p "$BACKUP" "$VAULT/90-Operator"/{dashboard,intents,runbooks,projects,services,assets,recovery,automation,operations}

move_if_exists() {
  src="$1"
  dst="$2"
  if [ -e "$VAULT/$src" ]; then
    mkdir -p "$(dirname "$VAULT/$dst")"
    echo "MOVE $src -> $dst"
    mv "$VAULT/$src" "$VAULT/$dst"
  fi
}

# Move new Obsidian control layer into 90-Operator
move_if_exists "00-dashboard" "90-Operator/dashboard"
move_if_exists "01-intents" "90-Operator/intents"
move_if_exists "02-runbooks" "90-Operator/runbooks"
move_if_exists "03-projects" "90-Operator/projects"
move_if_exists "04-services" "90-Operator/services"
move_if_exists "05-assets" "90-Operator/assets"
move_if_exists "06-recovery" "90-Operator/recovery"
move_if_exists "07-automation" "90-Operator/automation"
move_if_exists "08-operations" "90-Operator/operations"

# Keep legacy authority folders untouched:
# 00-Core, 01-Templates, 02-Policies, 03-Runbooks, 04-Network,
# 04-Schemas, 05-Registry, 06-Services, 07-Operations,
# 08-Intelligence, 09-Governance, 99-Archive

mkdir -p \
  "$VAULT/90-Operator/dashboard" \
  "$VAULT/90-Operator/intents" \
  "$VAULT/90-Operator/runbooks" \
  "$VAULT/90-Operator/projects" \
  "$VAULT/90-Operator/services" \
  "$VAULT/90-Operator/recovery" \
  "$VAULT/90-Operator/automation" \
  "$VAULT/90-Operator/operations" \
  "$VAULT/09-Governance/audit"

cat > "$VAULT/90-Operator/dashboard/home.md" <<'EOF_MD'
# Wonderland Operator Home

## Health

```bash
wl doctor
wl obsidian verify
wl obsidian list
Run Intents
wl obsidian run wl-status
wl obsidian run wl-doctor
wl obsidian run matrix-fluderation
Active Projects
[[../projects/THE-MATRIX/index|THE∅MATRIX]]
[[../projects/Wonderland/index|Wonderland]]
Operator Areas
[[../intents]]
[[../runbooks]]
[[../services]]
[[../recovery]]
[[../automation]]
[[../operations]]
Authority Layer
[[../../00-Core]]
[[../../03-Runbooks]]
[[../../06-Services]]
[[../../07-Operations]]
[[../../09-Governance]]
EOF_MD

cat > "$VAULT/90-Operator/dashboard/command-launcher.md" <<'EOF_MD'

Command Launcher
Health
wl doctor
wl obsidian verify
wl obsidian list
Intents
wl obsidian run wl-status
wl obsidian run wl-doctor
wl obsidian run matrix-fluderation
Vault
wl vault status
wl obsidian open

EOF_MD

cat > "$WL_HOME/bin/wl-obsidian" <<'EOF_OBS'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
VAULT="$WL_HOME/vault"
OPERATOR="$VAULT/90-Operator"
INTENTS="$OPERATOR/intents"
AUDIT="$VAULT/09-Governance/audit/obsidian-command-audit.log"

mkdir -p "$INTENTS" "$(dirname "$AUDIT")"

case "${1:-}" in
status)
echo "WL_HOME=$WL_HOME"
echo "VAULT=$VAULT"
echo "OPERATOR=$OPERATOR"
echo "INTENTS=$INTENTS"
test -d "$VAULT" && echo "PASS vault" || echo "FAIL vault"
test -d "$OPERATOR" && echo "PASS operator" || echo "FAIL operator"
test -d "$INTENTS" && echo "PASS intents" || echo "FAIL intents"
;;

open)
open "obsidian://open?path=$OPERATOR/dashboard/home.md"
;;

list)
find "$INTENTS" -maxdepth 1 -name '*.intent.json' -print | sort
;;

show)
name="${2:-}"
file="$INTENTS/$name.intent.json"
test -f "$file" || { echo "FAIL missing intent: $file"; exit 1; }
cat "$file"
;;

run)
name="${2:-}"
file="$INTENTS/$name.intent.json"
test -f "$file" || { echo "FAIL missing intent: $file"; exit 1; }

cmd="$(python3 - "$file" <<'PY'

import json, sys
data=json.load(open(sys.argv[1]))
cmd=data.get("command","").strip()
if not cmd:
raise SystemExit("missing command")
allowed=("$HOME/Wonderland/bin/wl ", "~/Wonderland/bin/wl ", "${WL_AUTHORITY_ROOT:-${WL_HOME:-$HOME/Wonderland}}/bin/wl ")
if not cmd.startswith(allowed):
raise SystemExit(f"unsafe command: {cmd}")
print(cmd)
PY
)"
printf '%s intent=%s command=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$name" "$cmd" >> "$AUDIT"
bash -lc "$cmd"
;;

verify)
fail=0
for p in "$VAULT" "$OPERATOR" "$INTENTS" "$OPERATOR/dashboard" "$OPERATOR/runbooks" "$VAULT/09-Governance/audit"; do
test -d "$p" && echo "PASS $p" || { echo "FAIL $p"; fail=1; }
done
test "$fail" -eq 0 && echo "RESULT PASS" || { echo "RESULT FAIL"; exit 1; }
;;

*)
echo "usage: wl-obsidian status | open | list | show <intent> | run <intent> | verify"
;;
esac
EOF_OBS

chmod +x "$WL_HOME/bin/wl-obsidian"

cat > "$VAULT/90-Operator/intents/wl-status.intent.json" <<EOF_JSON
{
"name": "wl-status",
"mode": "REVIEW",
"command": "$WL_HOME/bin/wl status",
"audit": true
}
EOF_JSON

cat > "$VAULT/90-Operator/intents/wl-doctor.intent.json" <<EOF_JSON
{
"name": "wl-doctor",
"mode": "REVIEW",
"command": "$WL_HOME/bin/wl doctor",
"audit": true
}
EOF_JSON

cat > "$VAULT/90-Operator/intents/matrix-fluderation.intent.json" <<EOF_JSON
{
"name": "matrix-fluderation",
"mode": "BUILD",
"command": "$WL_HOME/bin/wl matrix fluderation",
"audit": true
}
EOF_JSON

echo "PASS operator migration"
"$WL_HOME/bin/wl-obsidian" verify
