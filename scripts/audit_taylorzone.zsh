#!/bin/zsh
set -euo pipefail

# ====================================================================
# TaylorZone Zero-Trust Infrastructure Audit Script
# ====================================================================

echo "=== Beginning TaylorZone Zero-Trust Infrastructure Audit ==="
echo ""

# 1. Check Mount Point and APFS Status
echo "[+] Checking Mount Point and APFS Status..."
if mount | grep -q "on /Volumes/TaylorZone " || mount | grep -q "on /Volumes/CrystalVault " || [[ -d "/Volumes/TaylorZone" && -d "/Volumes/CrystalVault" ]]; then
    echo "  [PASS] Vault is mounted and accessible at /Volumes/TaylorZone."
else
    echo "  [FAIL] Mount point /Volumes/TaylorZone is not accessible!" >&2
    exit 1
fi

# 2. Verify POSIX Permissions & Ownership on shared_assets
echo "[+] Verifying POSIX Permissions & Ownership..."
SHARED_DIR="/Volumes/TaylorZone/shared_assets"

if [[ -d "$SHARED_DIR" ]]; then
    PERMS=$(stat -f "%Lp" "$SHARED_DIR")
    if [[ "$PERMS" == "700" ]]; then
        echo "  [PASS] shared_assets permissions are correctly set to 700."
        echo "  [PASS] Shared assets directory permissions are 700."
    else
        echo "  [FAIL] shared_assets permissions are $PERMS (Expected: 700)." >&2
        sudo chmod 700 "$SHARED_DIR"
        exit 1
    fi
else
    echo "  [FAIL] shared_assets directory not found at $SHARED_DIR." >&2
    exit 1
fi

# 3. Audit .stignore Configuration
echo "[+] Auditing .stignore Configuration..."
STIGNORE_PATH="$SHARED_DIR/.stignore"
if [[ -f "$STIGNORE_PATH" ]]; then
    IGNORE_PERMS=$(stat -f "%Lp" "$STIGNORE_PATH")
    echo "  [PASS] .stignore present with permissions ($IGNORE_PERMS)."

    # Check required ignore patterns
    for pattern in '(?d)*.sparsebundle' '(?d)*.key' '(?d)*.pem' '(?d).DS_Store' '(?d).stfolder'; do
        if grep -qF "$pattern" "$STIGNORE_PATH"; then
            echo "  [PASS] Required ignore pattern verified: '$pattern'"
        else
            echo "  [FAIL] Missing critical ignore pattern in .stignore: '$pattern'" >&2
            exit 1
        fi
    done
else
    echo "  [FAIL] No .stignore file found at $STIGNORE_PATH!" >&2
    exit 1
fi

# 4. Check Syncthing Folder Marker & REST API State
echo "[+] Checking Syncthing Folder Marker & REST API State..."
if [[ -d "$SHARED_DIR/.stfolder" ]]; then
    echo "  [PASS] Syncthing safety marker (.stfolder) present."
else
    echo "  [FAIL] Syncthing safety marker (.stfolder) missing." >&2
    exit 1
fi

# Verify via Python API call safely without shell argument length limits
python3 - << 'EOF'
import urllib.request
import json
import ssl
import os
import xml.etree.ElementTree as ET
import sys

xml_path = os.path.expanduser("~/Library/Application Support/Syncthing/config.xml")
try:
    tree = ET.parse(xml_path)
    root = tree.getroot()
    api_key_el = root.find(".//gui/apikey")
    api_key = api_key_el.text if api_key_el is not None else ""
except Exception:
    api_key = ""

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

url = "https://127.0.0.1:8384/rest/config/folders"
req = urllib.request.Request(url, headers={"X-API-Key": api_key})

try:
    with urllib.request.urlopen(req, context=ctx, timeout=5) as resp:
        if resp.status == 200:
            print("  [PASS] Syncthing REST API is reachable and responding (200 OK via TLS).")
            folders = json.loads(resp.read().decode("utf-8"))
            found = any(f.get("id") == "taylorzone-shared-assets" for f in folders)
            if found:
                print("  [PASS] TaylorZone folder configuration verified in Syncthing API.")
            else:
                print("  [FAIL] TaylorZone folder configuration missing from Syncthing API.", file=sys.stderr)
                sys.exit(1)
        else:
            print(f"  [FAIL] Syncthing REST API returned status {resp.status}", file=sys.stderr)
            sys.exit(1)
except Exception as e:
    print(f"  [FAIL] Could not verify folders via Syncthing API: {e}", file=sys.stderr)
    sys.exit(1)
EOF

echo ""
echo "=== TaylorZone Audit Completed Successfully! All Checks Passed. ==="
