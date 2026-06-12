#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p \
  "$ROOT/.wl/state" \
  "$ROOT/.wl/snapshots" \
  "$ROOT/.wl/manifests" \
  "$ROOT/templates"

cat > "$ROOT/.wl/manifests/architect.manifest" <<EOF
00-governance/architect-charter.md
00-governance/standards.md
01-overview/wonderland-overview.md
08-handoffs/handoff-standard.md
09-reviews/review-framework.md
10-roadmap/roadmap.md
99-inbox/inbox.md
intents/chatgpt-architect.intent.json
EOF

cat > "$ROOT/bin/wlv4" <<EOF
#!/usr/bin/env bash
exec "$ROOT/bin/wl" "\$@"
EOF

chmod +x "$ROOT/bin/wlv4"

echo "Architect installed."
echo
echo "Use:"
echo "  $ROOT/bin/wlv4 architect verify"
