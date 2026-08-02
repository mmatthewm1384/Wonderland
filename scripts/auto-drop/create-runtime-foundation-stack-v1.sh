#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
PKG_ROOT="$WL_ROOT/scripts/auto-drop/packages"

PACKAGES=(
runtime-target-registry-v1
runtime-target-resolver-v1
runtime-adapter-lima-v1
runtime-service-adapter-wiring-v1
runtime-state-store-v1
runtime-foundation-v1
)

create_package() {
    local name="$1"
    local dir="$PKG_ROOT/$name"

    mkdir -p \
        "$dir/artifacts" \
        "$dir/scripts" \
        "$dir/certification"

    cat > "$dir/manifest.json" <<EOF
{
  "name": "$name",
  "version": "1.0.0",
  "type": "capability",
  "classification": "runtime",
  "lifecycle": {
    "install": "scripts/install.sh",
    "verify": "scripts/verify.sh",
    "rollback": "scripts/rollback.sh"
  },
  "certification": {
    "schema": "certification/schema.json"
  }
}
EOF

    cat > "$dir/artifacts/metadata.yaml" <<EOF
name: $name
version: 1.0.0
category: runtime
status: generated
governance:
  approval_required: true
  evidence_required: true
EOF

    cat > "$dir/certification/schema.json" <<EOF
{
  "schema_version": "1.0",
  "required": [
    "name",
    "version",
    "certification"
  ]
}
EOF

    cat > "$dir/scripts/install.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
echo "INSTALL $name"
EOF

    cat > "$dir/scripts/verify.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail

ROOT="\$(cd "\$(dirname "\$0")/.." && pwd)"

test -f "\$ROOT/manifest.json"
test -f "\$ROOT/artifacts/metadata.yaml"
test -f "\$ROOT/certification/schema.json"

test -x "\$ROOT/scripts/install.sh"
test -x "\$ROOT/scripts/verify.sh"
test -x "\$ROOT/scripts/rollback.sh"

echo "CERTIFIED"
EOF

    cat > "$dir/scripts/rollback.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
echo "ROLLBACK $name"
EOF

    chmod +x "$dir/scripts/"*.sh

    echo "CREATED $name"
}


mkdir -p "$PKG_ROOT"

for pkg in "${PACKAGES[@]}"; do
    create_package "$pkg"
done

echo
echo "Runtime foundation stack generated."
