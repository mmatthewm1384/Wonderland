#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

echo "== Wonderland wl command path repair =="

WL="$ROOT/bin/wl"
PLATFORM="$ROOT/bin/wl-platform"

if [ ! -x "$WL" ]; then
    echo "FAIL missing: $WL"
    exit 1
fi

if [ ! -x "$PLATFORM" ]; then
    echo "FAIL missing: $PLATFORM"
    exit 1
fi

echo
echo "Current launchers:"
echo "  $WL"
echo "  $PLATFORM"

echo
echo "Checking wl delegation..."

grep -n "wl-platform" "$WL" || true

echo
echo "Testing direct platform launcher..."

"$PLATFORM" certify trust >/tmp/wl-platform-certify-test.json

if grep -q CERTIFIED /tmp/wl-platform-certify-test.json; then
    echo "PASS: platform launcher certification works"
else
    echo "FAIL: platform launcher certification failed"
    cat /tmp/wl-platform-certify-test.json
    exit 1
fi

echo
echo "Repairing bin/wl if needed..."

cat > "$WL" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

case "${1:-}" in
    platform)
        shift
        exec "$ROOT/bin/wl-platform" "$@"
        ;;
    *)
        exec "$ROOT/bin/wl-platform" "$@"
        ;;
esac
EOF

chmod +x "$WL"

echo
echo "Verification:"
"$WL" platform certify trust

echo
echo "DONE"
